package flex.samples.marketfeed;

import java.io.Serializable;
import java.util.Date;

/**
 * @author Christophe Coenraets
 */
public class Stock implements Serializable {

    private static final long serialVersionUID = -1763421100056755200L;

    protected String symbol;

    protected String name;

    protected double low;

    protected double high;

    protected double open;

    protected double last;

    protected double change;

    protected Date date;

    public double getChange() {
        return this.change;
    }

    public void setChange(double change) {
        this.change = change;
    }

    public double getHigh() {
        return this.high;
    }

    public void setHigh(double high) {
        this.high = high;
    }

    public double getLast() {
        return this.last;
    }

    public void setLast(double last) {
        this.last = last;
    }

    public double getLow() {
        return this.low;
    }

    public void setLow(double low) {
        this.low = low;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public double getOpen() {
        return this.open;
    }

    public void setOpen(double open) {
        this.open = open;
    }

    public String getSymbol() {
        return this.symbol;
    }

    public void setSymbol(String symbol) {
        this.symbol = symbol;
    }

    public Date getDate() {
        return this.date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

}
