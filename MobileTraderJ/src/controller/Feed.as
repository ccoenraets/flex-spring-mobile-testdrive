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

	[Event(name="fault", type="mx.events.DynamicEvent")]
	public class Feed extends EventDispatcher
	{
		public static var messageBrokerURL:String = "http://localhost:8080/flex-spring-mobile/messagebroker";
		
		public static var channel:String = "streamingamf";
		
		protected var feedManager:RemoteObject;
		
		protected var consumer:MultiTopicConsumer;
		
		[Bindable]
		public var stockList:ArrayCollection;
		
		protected var stockMap:Dictionary;
		
		protected var token:AsyncToken;
		
		public function Feed()
		{
			feedManager = new RemoteObject("feedManager");
			feedManager.endpoint = messageBrokerURL + "/amf";
			
			trace("getStocks");
			token = feedManager.getStocks();
			token.addResponder(new AsyncResponder(getStocks_result, feedManager_fault));
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
//			list.dataProvider = stockList;
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
			}
		}
		
		protected function feedManager_fault(event:FaultEvent, token:AsyncToken):void
		{
			trace("error:" + event.fault.faultString);
			if (event.fault.faultDetail)
			{
				trace(event.fault.faultDetail);
				var e:DynamicEvent = new DynamicEvent("fault");
				e.faultDetail = event.fault.faultDetail;
				e.faultString = event.fault.faultString;
				dispatchEvent(e);
			}
		}

		protected function consumer_fault(event:MessageFaultEvent):void
		{
			if (event.faultDetail)
			{
				trace(event.faultDetail);
				var e:DynamicEvent = new DynamicEvent("fault");
				e.faultDetail = event.faultDetail;
				e.faultString = event.faultString;
				dispatchEvent(e);
			}
		}
		
		

	
	
	}
}