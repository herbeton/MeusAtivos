import models
import yfinance
import uvicorn
import csv
from fastapi import FastAPI, Request, Depends, BackgroundTasks
from fastapi.templating import Jinja2Templates
from database import SessionLocal, engine
from sqlalchemy.orm import Session
from pydantic import BaseModel
from models import Stock, StockEUA

app = FastAPI()

models.Base.metadata.create_all(bind=engine)

templates = Jinja2Templates(directory="templates")

class StockRequest(BaseModel):
    symbol: str

def get_db():
    try:
        db = SessionLocal()
        yield db
    finally: 
        db.close()

@app.get("/")
def dashboard(request: Request, forward_pe = None, dividend_yield = None, ma50 = None, ma200 = None, db: Session = Depends(get_db)):
    """
    show all stocks in the db and button to add more
    button next to each stock to delete from db
    filters to filter this list of stocks
    button next to each to add a note or save for later
    """

    stocks = db.query(Stock)

    if forward_pe:
        stocks = stocks.filter(Stock.forward_pe < forward_pe)

    if dividend_yield:
        stocks = stocks.filter(Stock.dividend_yield > dividend_yield)
    
    if ma50:
        stocks = stocks.filter(Stock.price > Stock.ma50)

    if ma200:
        stocks = stocks.filter(Stock.price > Stock.ma200)

    stocks = stocks.all()

    return templates.TemplateResponse("dashboard.html", {
        "request": request,
        "stocks": stocks,
        "dividend_yield": dividend_yield,
        "forward_pe": forward_pe,
        "ma200": ma200, 
        "ma50": ma50 
    }) 

def fetch_stock_data(id: int):
    
    db = SessionLocal()
    
    stock = db.query(Stock).filter(Stock.id == id).first()

    
    yahoo_data = yfinance.Ticker(stock.symbol)

    stock.ma200 = yahoo_data.info['twoHundredDayAverage']
    stock.ma50 = yahoo_data.info['fiftyDayAverage']
    stock.price = yahoo_data.info['previousClose']
    stock.forward_pe = yahoo_data.info['forwardPE']
    stock.forward_eps = yahoo_data.info['forwardEps']
    stock.dividend_yield = yahoo_data.info['dividendYield'] * 100

    db.add(stock)
    db.commit()

@app.post("/stock")
async def create_stock(stock_request: StockRequest, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    """
    add one or more tickers to the database
    background task to use yfinance and load key statistics
    """
    
    stock = Stock()
    stock.symbol = stock_request.symbol
    db.add(stock)
    db.commit()

    background_tasks.add_task(fetch_stock_data, stock.id)

    return {
        "code": "success",
        "message": "stock created"
    }


@app.post("/stockArchiveEua")
async def create_stock(stock_request: StockRequest, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    """
    add one or more tickers to the database
    background task to use yfinance and load key statistics
    """

    stock = Stock()
    stock.symbol = stock_request.symbol
    file = open(stock.symbol)
    file2 = 'archives/nasdaq_screener_1695743571924.csv'
    type(file)
    # readCSV = csv.reader(file, delimiter=',')
    x = open(file2)

    with open(file2) as csvfile:
        readCSV = csv.reader(csvfile, delimiter=',')
        for row in readCSV:
            if(row[0] != 'Symbol'):
                print(row)
                print(row[0], row[1], row[2], row[6], row[7], row[8], row[9], row[10])
                stockEUA = StockEUA()
                stockEUA.symbol = row[0]
                stockEUA.name = row[1]
                stockEUA.marketCap = row[5]
                stockEUA.country = row[6]
                stockEUA.ipoYear = row[7]
                stockEUA.volume = row[8]
                stockEUA.sector = row[9]
                stockEUA.industry = row[10]
                db.add(stockEUA)

        db.commit()

    return {
        "code": "success",
        "message": "stock created"
    }


@app.delete("/stock")
async def create_stock(stock_request: StockRequest, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    """
    add one or more tickers to the database
    background task to use yfinance and load key statistics
    """

    stock = Stock()
    stock.symbol = stock_request.symbol
    db.add(stock)
    db.commit()

    background_tasks.add_task(fetch_stock_data, stock.id)

    return {
        "code": "success",
        "message": "stock created"
    }
# para tirar o erro ->  pip install typing-extensions --upgrade
if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8010)