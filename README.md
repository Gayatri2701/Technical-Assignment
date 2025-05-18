# Technical-Assignment
Employees Compensation Forecasting Application 

A Full-Stack Application Using Streamlit & MySQL

---

## Table of Contents

1. Tools and Technologies Used
2. How to Set Up the Database and Run the Application
3. Description of Each User Story and How It Is Fulfilled
4. Optional: Screenshots

---

## 1. Tools and Technologies Used

### 1.1 Frontend

* Python 3.8+: Primary language for building the Streamlit app.
* Streamlit: Interactive web interface with charts, filters, and buttons.
* Pandas: Data handling and manipulation.
* openpyxl: To read Excel (.xlsx) files.
* mysql-connector-python: To connect to MySQL (optional if not reading Excel).

### 1.2 Backend

* MySQL 8+: Relational database for normalized employee data.
* Stored Procedures:

  * `FilterEmployees`: Filter based on role, location, and status.
  * `CalculateAverageCompensation`: Group-wise aggregation.
  * `ApplyIncrement`: Apply compensation increments.
  * `GetFilteredData`: Full exportable dataset.
* MySQL Workbench: GUI to manage SQL scripts.

### 1.3 Data Sources

* Excel or CSV: Source files with employee data.

### 1.4 Directory Structure

```
project/
├── employee_dashboard.py
├── employee_data.xlsx
├── sql/
│   ├── database creation and data import.sql
│   ├── Normalize table creation and adding records.sql
│   └── procedures.sql
├── README.md
└── screenshots/
```

---

## 2. How to Set Up the Database and Run the Application

### 2.1 Database Setup

1. Install MySQL and MySQL Workbench.
2. Run the following SQL scripts in order:

   * database creation and data import.sql
   * Normalize table creation and adding records.sql
   * procedures.sql
3. Ensure LOAD DATA INFILE is enabled:

   ```sql
   SET GLOBAL local_infile = 1;
   ```
4. Update file path in script to your CSV location.

### 2.2 Streamlit Frontend Setup

1. Install Python and required packages:

   ```bash
   pip install streamlit pandas openpyxl mysql-connector-python
   ```
2. Place employee\_dashboard.py and employee\_data.xlsx correctly.
3. Run the app:

   ```bash
   streamlit run employee_dashboard.py
   ```

### 2.3 (Optional) Connect Streamlit to MySQL

Replace Excel load logic with:

```python
import mysql.connector
conn = mysql.connector.connect(
    host='localhost', user='root', password='yourpassword', database='EmployeeDB')
cursor = conn.cursor(dictionary=True)
cursor.execute("CALL GetFilteredData();")
df = pd.DataFrame(cursor.fetchall())
```

### 2.4 (Optional) Persist Increments to DB

Add this logic under Apply Increment:

```python
if st.button("Apply Increment to DB"):
    cursor.execute("CALL ApplyIncrement(%s)", (percent,))
    conn.commit()
```

---

## 3. Description of Each User Story and Fulfillment

### User Story 1: Filter by Role, Location, Status

* Filters: Role, Location, Include Inactive?
* Metrics: Avg Compensation in selected Location
* Chart: Bar chart of avg comp across all locations
* Procedure: `FilterEmployees`, `CalculateAverageCompensation`

### User Story 2: Group by Experience

* Groups by 'Years of Experience' (e.g., 1-2, 2-3)
* Optional breakdown: by Location or Role
* Pandas logic + Streamlit bar\_chart

### User Story 3: Simulate Increments

* Modes: Global %, Per Location %, Per Employee %
* Output: Current vs. New Compensation side-by-side
* Bonus: Bonus = 10%, Stock = 12%, Total = All
* Optional: `ApplyIncrement` procedure to persist

### User Story 4: Download Data

* Filter: Active Status (All, Y, N)
* Output: Export filtered table to CSV
* Procedure: `GetFilteredData`

---

## 4. Screenshots

Place your screenshots in the /screenshots folder and reference them below:

```
![Screenshot 2025-05-17 220823](https://github.com/user-attachments/assets/60fd3575-c985-4b65-a009-ed301677d9ff)
![Screenshot 2025-05-17 220835](https://github.com/user-attachments/assets/c08ca857-9aa1-4474-856f-5c0d369534fd)
![Screenshot 2025-05-17 220703](https://github.com/user-attachments/assets/39d81000-10ee-4177-9151-3f081949df5b)
![Screenshot 2025-05-17 220638](https://github.com/user-attachments/assets/5e423cb8-dafc-4784-8898-34fdcfff6201)
![Screenshot 2025-05-17 220746](https://github.com/user-attachments/assets/9a69888b-df0b-4b4b-846f-2f27a97d39ee)

```

---

