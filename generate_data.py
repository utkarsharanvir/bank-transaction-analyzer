import sqlite3
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker('en_IN')
conn = sqlite3.connect(r'C:\Users\Tanu\Desktop\bank_analyzer.db')
cursor = conn.cursor()

# Insert customers
cities = ['Mumbai', 'Delhi', 'Pune', 'Bangalore', 'Chennai', 'Hyderabad']
for i in range(1, 51):
    cursor.execute("INSERT INTO customers VALUES (?, ?, ?, ?)", (
        i,
        fake.name(),
        random.choice(cities),
        fake.date_between(start_date='-3y', end_date='-1y')
    ))

# Insert accounts
types = ['savings', 'current']
for i in range(1, 101):
    cursor.execute("INSERT INTO accounts VALUES (?, ?, ?, ?)", (
        i,
        random.randint(1, 50),
        random.choice(types),
        round(random.uniform(1000, 500000), 2)
    ))

# Insert transactions
categories = ['salary', 'rent', 'food', 'shopping', 'transfer', 'utilities', 'medical']
for i in range(1, 501):
    cursor.execute("INSERT INTO transactions VALUES (?, ?, ?, ?, ?, ?)", (
        i,
        random.randint(1, 100),
        fake.date_between(start_date='-1y', end_date='today'),
        random.choice(['credit', 'debit']),
        round(random.uniform(100, 50000), 2),
        random.choice(categories)
    ))

conn.commit()
conn.close()
print("Done! 500 transactions inserted successfully.")