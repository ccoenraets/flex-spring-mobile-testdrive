package controller
{
	import flash.events.EventDispatcher;
	import flash.net.Responder;
	import flash.utils.Dictionary;
	
	import model.Stock;
	
	import mx.collections.ArrayCollection;
	import mx.events.DynamicEvent;
	import mx.messaging.ChannelSet;
	import mx.messaging.MultiTopicConsumer;
	import mx.messaging.channels.AMFChannel;
	import mx.messaging.channels.StreamingAMFChannel;
	import mx.messaging.events.MessageEvent;
	import mx.messaging.events.MessageFaultEvent;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	import spark.managers.PersistenceManager;

	[Bindable]
	[Event(name="fault", type="mx.events.DynamicEvent")]
	[Event(name="configFault", type="mx.events.DynamicEvent")]
	public class Feed extends EventDispatcher
	{
		protected var persistenceManager:PersistenceManager = new PersistenceManager();;
		
		public var messageBrokerURL:String;
		
		public var channel:String = "streamingamf";
		
		protected var feedManager:RemoteObject;
		
		protected var consumer:MultiTopicConsumer;
		
		public var stockList:ArrayCollection;
		
		protected var stockMap:Dictionary;
		
		protected var token:AsyncToken;
		
		public function Feed()
		{
		}
		
		public function getStocks():void
		{
			trace("getStocks");
			token = feedManager.getStocks();
			token.addResponder(new AsyncResponder(getStocks_result, feedManager_fault));
		}

		public function start():void
		{
			feedManager.start();
		}

		public function stop():void
		{
			feedManager.stop();
		}

		public function subscribe():void
		{
			if (consumer)
				consumer.subscribe();
		}
	
		public function unsubscribe():void
		{
			if (consumer)
			{
	 			consumer.unsubscribe();
				consumer.disconnect();
			}
		}
		
		protected function getStocks_result(event:ResultEvent, token:AsyncToken):void
		{
			trace("getStocks_result");
			stockList = event.result as ArrayCollection;
			stockMap = new Dictionary();
			var stock:Stock;

			consumer = new MultiTopicConsumer();
			consumer.destination = "market-feed";
			var amfChannel:AMFChannel = channel == "streamingamf" ? new StreamingAMFChannel() : new AMFChannel();
			amfChannel.uri = messageBrokerURL + "/" + channel;
			var cs:ChannelSet = new ChannelSet();
			cs.addChannel(amfChannel);
			consumer.channelSet = cs;
			consumer.addEventListener(MessageEvent.MESSAGE, messageHandler);
			consumer.addEventListener(FaultEvent.FAULT, consumer_fault);
			for (var i:int=0; i<stockList.length; i++)
			{
				stock = stockList.getItemAt(i) as Stock;
				stockMap[stock.symbol] = stock; 
				consumer.addSubscription(stock.symbol);
			}
			consumer.subscribe();
		}
		
		protected function messageHandler(event:MessageEvent):void 
		{
			var changedStock:Stock = event.message.body as Stock;
			var stock:Stock = stockMap[changedStock.symbol];
			if (stock)
			{
				stock.open = changedStock.open;
				stock.change = changedStock.change;
				stock.last = changedStock.last;
				stock.high = changedStock.high;
				stock.low = changedStock.low;
				stock.date = changedStock.date;
				
				if (!stock.history)
					stock.history = new ArrayCollection();
				if (stock.history.length == 40)
					stock.history.removeItemAt(0);
				stock.history.addItem(changedStock);
				
			}
		}
		
		protected function feedManager_fault(event:FaultEvent, token:AsyncToken):void
		{
			if (event.fault.faultDetail)
				dispatchFaultEvent("fault", event.fault.faultString, event.fault.faultDetail);
		}

		protected function consumer_fault(event:MessageFaultEvent):void
		{
			if (event.faultDetail)
				dispatchFaultEvent("fault", event.faultString, event.faultDetail);
		}
		
		public function setConfig(messageBrokerURL:String, channel:String):void
		{
			if (messageBrokerURL != this.messageBrokerURL || channel != this.channel)
			{
				this.messageBrokerURL = messageBrokerURL;
				this.channel = channel;
				persistenceManager.setProperty("messageBrokerURL", messageBrokerURL);
				persistenceManager.setProperty("channel", channel);
				persistenceManager.save();
				
				feedManager = new RemoteObject("feedManager");
				feedManager.endpoint = messageBrokerURL + "/amf";
				getStocks();
			}
		}
		
		public function loadConfig():void
		{
			if (!persistenceManager.load())
			{
				dispatchFaultEvent("configFault", "Configuration Error", "Configure MessageBroker URL in Settings Tab");
				return;
			}
			
			var property:Object = persistenceManager.getProperty("messageBrokerURL");
			if (property) 
			{
				messageBrokerURL = property.toString();
			}
			else
			{
				dispatchFaultEvent("configFault", "Configuration Error", "Please configure the MessageBroker URL in Settings Tab");
				return;
			}
			
			property = persistenceManager.getProperty("channel");
			if (property) 
			{
				channel = property.toString();
			}
			else
			{
				dispatchFaultEvent("configFault", "Configuration Error", "Please configure channel in Settings Tab");
				return;
			}
			
			feedManager = new RemoteObject("feedManager");
			feedManager.endpoint = messageBrokerURL + "/amf";
			getStocks();
			
		}
		
		protected function dispatchFaultEvent(type:String, faultString:String, faultDetail:String):void
		{
			var e:DynamicEvent = new DynamicEvent(type);
			e.faultString = faultString;
			e.faultDetail = faultDetail;
			dispatchEvent(e);
		}
		
	
	}
}