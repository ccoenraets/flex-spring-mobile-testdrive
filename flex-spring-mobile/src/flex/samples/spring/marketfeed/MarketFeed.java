package flex.samples.spring.marketfeed;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Random;

import javax.xml.parsers.DocumentBuilderFactory;

import org.springframework.core.io.Resource;
import org.springframework.flex.messaging.AsyncMessageCreator;
import org.springframework.flex.messaging.MessageTemplate;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import flex.messaging.messages.AsyncMessage;
import flex.samples.marketfeed.Stock;


/**
 * @author Christophe Coenraets
 */
public class MarketFeed {

    private static FeedThread thread;

    private final MessageTemplate template;

    private final List<Stock> stockList;

    public MarketFeed(MessageTemplate template, Resource filePath) throws IOException {
        this.template = template;
        this.stockList = getStocks(filePath.getFile());
    }

    public void start() {
        if (thread == null) {
            thread = new FeedThread(this.template, this.stockList);
            thread.start();
        }
    }

    public void stop() {
        thread.running = false;
        thread = null;
    }

    private List<Stock> getStocks(File file) {

        List<Stock> list = new ArrayList<Stock>();

        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setValidating(false);
            Document doc = factory.newDocumentBuilder().parse(file);
            NodeList stockNodes = doc.getElementsByTagName("stock");
            int length = stockNodes.getLength();
            Stock stock;
            Node stockNode;
            for (int i = 0; i < length; i++) {
                stockNode = stockNodes.item(i);
                stock = new Stock();
                stock.setSymbol(getStringValue(stockNode, "symbol"));
                stock.setName(getStringValue(stockNode, "company"));
                stock.setLast(getDoubleValue(stockNode, "last"));
                stock.setHigh(stock.getLast());
                stock.setLow(stock.getLast());
                stock.setOpen(stock.getLast());
                stock.setChange(0);
                list.add(stock);
                System.out.println(stock.getSymbol());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Stock> getStocks() {
    	return stockList;
    }
    
    private String getStringValue(Node node, String name) {
        return ((Element) node).getElementsByTagName(name).item(0).getFirstChild().getNodeValue();
    }

    private double getDoubleValue(Node node, String name) {
        return Double.parseDouble(getStringValue(node, name));
    }

    public static class FeedThread extends Thread {

        public boolean running = false;

        private final MessageTemplate template;

        private final List<Stock> stockList;

        private final Random random = new Random();

        public FeedThread(MessageTemplate template, List<Stock> stockList) {
            this.template = template;
            this.stockList = stockList;
        }

        @Override
        public void run() {
            this.running = true;

            int size = this.stockList.size();
            int index = 0;

            Stock stock;

            while (this.running) {

                stock = this.stockList.get(index);
                simulateChange(stock);

                index++;
                if (index >= size) {
                    index = 0;
                }

                sendStockUpdate(stock);

                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                }

            }
        }

        private void sendStockUpdate(final Stock stock) {
            template.send(new AsyncMessageCreator() {

                public AsyncMessage createMessage() {
                    AsyncMessage msg = template.createMessageForDestination("market-feed");
                    msg.setHeader("DSSubtopic", stock.getSymbol());
                    msg.setBody(stock);
                    return msg;
                }
            });
        }

        private void simulateChange(Stock stock) {
            double maxChange = stock.getOpen() * 0.005;
            double change = maxChange - this.random.nextDouble() * maxChange * 2;
            stock.setChange(change);
            double last = stock.getLast() + change;

            if (last < stock.getOpen() + stock.getOpen() * 0.15 && last > stock.getOpen() - stock.getOpen() * 0.15) {
                stock.setLast(last);
            } else {
                stock.setLast(stock.getLast() - change);
            }

            if (stock.getLast() > stock.getHigh()) {
                stock.setHigh(stock.getLast());
            } else if (stock.getLast() < stock.getLow()) {
                stock.setLow(stock.getLast());
            }
            stock.setDate(new Date());
        }

    }

}
