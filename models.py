from sqlalchemy import Column, String, Numeric, Integer

from database import Base


class Stock(Base):
    __tablename__ = "stocks"

    id = Column(Integer, primary_key=True, index=True)
    symbol = Column(String, unique=True, index=True)
    price = Column(Numeric(10, 2))
    forward_pe = Column(Numeric(10, 2))
    forward_eps = Column(Numeric(10, 2))
    dividend_yield = Column(Numeric(10, 2))
    ma50 = Column(Numeric(10, 2))
    ma200 = Column(Numeric(10, 2))

class StockEUA(Base):
    __tablename__ = "stocks-eua"

    id = Column(Integer, primary_key=True, index=True)
    symbol = Column(String, unique=True, index=True)
    name = Column(String, unique=False, index=True)
    marketCap = Column(String, unique=False, index=True)
    country = Column(String, unique=False, index=True)
    ipoYear = Column(String, unique=False, index=True)
    volume = Column(String, unique=False, index=True)
    sector = Column(String, unique=False, index=True)
    industry = Column(String, unique=False, index=True)