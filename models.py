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

    __tablename__ = "stocks-eua"

    id = Column(Integer, primary_key=True, index=True)
    symbol = Column(String, unique=True, index=True)
    marketCap = Column(Numeric(20, 2))
    Country = Column(String, unique=True, index=True)
    ipoYear = Column(Numeric(10, 2))
    volume = Column(Numeric(20, 2))
    sector = Column(String, unique=True, index=True)
    Industry = Column(String, unique=True, index=True)

    