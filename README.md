# Technical-Assignment
Employees Compensation Forecasting Application 

A Full-Stack Business Application with Streamlit + MySQL

───────────────────────────────────────────────────────────────

Sections:

1. Tools and Technologies Used  
2. Initial Data Preparation Using Excel  
3. How to Set Up the Database and Run the Application  
4. Description of Each User Story and How It Is Fulfilled  
5. Optional: Screenshots
6. Recommendations

───────────────────────────────────────────────────────────────

## 1. Tools and Technologies Used

Frontend:

- Python 3.8+:

  - Used to develop the entire Streamlit application.  
  - Handles data manipulation (with pandas), business logic, and interaction with backend SQL procedures.

- Streamlit:

  - Web application framework that allows fast development of browser-based dashboards with minimal code.  
  - Renders charts, filter widgets, metric displays, tables, and download buttons.

- pandas:

  - Performs DataFrame transformations, filtering, grouping, and compensation simulations.  
  - Reads from Excel (.xlsx) and prepares data for display and export.

- openpyxl:

  - Required by pandas to read Excel files into DataFrames.

- mysql-connector-python (optional):

  - Enables the Streamlit frontend to call stored procedures directly in MySQL if Excel import is not used.

Backend:

- MySQL:

  - Relational database used to store employee data in a normalized format.  
  - Ensures referential integrity across Role, Location, TurnoverStatus, Employee, and Compensation tables.  
  - Data is imported from a staging table.

- SQL Scripts:

  - `database creation and data import.sql`  
  - `Normalize table creation and adding records.sql`  
  - `procedures.sql`

- Stored Procedures:

  - Encapsulate reusable business logic such as filtering employees, calculating average compensation, and applying increments.

───────────────────────────────────────────────────────────────

## 2. Initial Data Preparation Using Excel

Before importing the data into the MySQL backend and building the Streamlit dashboard, thorough data cleaning and preliminary analysis were performed using Microsoft Excel to ensure data accuracy and enrich the dataset.

Steps and Techniques Used:

- Data Cleaning:

  - Removed empty and irrelevant columns to reduce noise.  
  - Filled missing values in the Years of Experience column to maintain data consistency.

- Data Enrichment:

  - Merged external industry compensation data to benchmark employee salaries.  
  - Added calculated columns for:  
    - Bonus Eligibility: 10% of base compensation.  
    - Stock Units Eligibility: 10% of base compensation.

- Total Compensation Calculation:

  - Computed a new Total Compensation column by summing base salary, bonus, and stock units.

- Pivot Table Analysis:

  - Summarized key HR metrics such as:  
    - Employee exits by Location and Role.  
    - Turnover percentage by department and geography.

- Excel Formulas Used:

  - Utilized formulas like IF(), VLOOKUP(), SUM(), and conditional aggregation to automate calculations and create dynamic reports.

This Excel-driven data preparation was critical in producing a clean, enriched dataset that feeds into the normalized MySQL schema and drives the business logic and visualizations within the Streamlit application.

───────────────────────────────────────────────────────────────

## 3. How to Set Up the Database and Run the Application

### 3.1. Set Up the MySQL Backend

Step 1: Install MySQL Server & Workbench  
→ https://dev.mysql.com/downloads/mysql/  
→ Install MySQL Workbench for GUI

Step 2: Run Scripts in Order

A. `database creation and data import.sql`

- Creates the EmployeeDB schema and a StagingEmployee table.  
- Loads raw employee data from a local CSV (adjust the path to your local system).  
- Use `SET GLOBAL local_infile = 1;` if needed.

B. `Normalize table creation and adding records.sql`

- Creates the following normalized tables:  
  - Role, Location, TurnoverStatus  
  - Employee (contains FK references to RoleID, LocationID, StatusID)  
  - Compensation (stores salary, bonus, stock data)  
- Populates the normalized tables using `INSERT ... SELECT JOIN` logic from the staging table.

C. `procedures.sql`

- Creates four stored procedures:  
  1. FilterEmployees(p_RoleID, p_LocationID, p_IncludeInactive)  
  2. CalculateAverageCompensation()  
  3. ApplyIncrement(p_Percent)  
  4. GetFilteredData()

### 3.2. Set Up the Frontend (Streamlit)

Step 1: Install Python 3.8+  
→ https://www.python.org/downloads/

Step 2: Install Required Packages

```bash
pip install streamlit pandas openpyxl mysql-connector-python

```

Step 3: File Placement

Save app.py and employee_data.xlsx in your working directory.

(e.g., C:\Users\USER\employee_data.xlsx, C:\Users\USER\app.py).

Step 4: Run the App in the Command Prompt

```bash
streamlit run app.py
```

### 4. Description of Each User Story and How It Is Fulfilled


### USER STORY 1: Filter and Display Active Employees by Role

As a user, I should be able to:

- Filter employees by Role
- Select a Location and view average compensation
- View a bar chart comparing compensation across locations
- Toggle to include/exclude inactive employees
- View fields: Name, Role, Location, Compensation

####  Streamlit Implementation

- `st.multiselect("Role")` filters roles:
  ```python
  df[df["Role"].isin(selected_roles)]

* `st.selectbox("Location")` filters and calculates:

  ```python
  df[df["Location"] == selected_location]["Current Comp (INR)"].mean()
  ```

* Checkbox toggles whether inactive employees (`Active? == "N"`) are included

* `st.metric()` displays average compensation of selected location

* `st.bar_chart()` shows compensation comparison across locations using `groupby`

#### 🛠️ SQL Integration (Optional)

* Stored Procedure: `CALL FilterEmployees(roleID, locationID, includeInactive)`
* Stored Procedure: `CALL CalculateAverageCompensation()`

These allow server-side filtering and compensation average calculation if integrated with MySQL.

---

### USER STORY 2: Group Employees by Years of Experience

**As a user, I should be able to:**

* View employee counts in experience ranges
* Group them optionally by Role or Location

####  Streamlit Implementation

* Uses `.value_counts()` on `'Years of Experience'` for overall distribution
* Advanced grouping using:

  ```python
  df.groupby(['Years of Experience', group_by_option])
  ```
* Displays results with `st.bar_chart()`

####  Business Logic

* Assumes experience data in string ranges like `"0-1"`, `"1-2"` etc.
* Preserves consistent labeling without converting to numeric bins
* Optional enhancement: implement SQL `GROUP BY` queries for grouping

---

### USER STORY 3: Simulate Compensation Increments

As a user, I should be able to:

* Apply a global % increment
* View old vs. new compensation side by side
* (Bonus) Define custom % increments per Location or per Employee

#### Streamlit Implementation

* `st.radio()` lets user select increment mode:

  * Global %
  * Per Location %
  * Per Employee %

* `st.slider()` allows user to input % value

* Compensation updated with:

  ```python
  df["New Comp (INR)"] = df["Current Comp (INR)"] * (1 + percent / 100)
  ```

####  SQL Integration (Optional)

* Stored Procedure: `CALL ApplyIncrement(10.00)` updates:

  * `CurrentComp`
  * `Bonus = 10% of New Comp`
  * `StockUnits = 12% of New Comp`
  * `TotalComp = Comp + Bonus + Stock`

* To apply increment from frontend:

  ```python
  if st.button("Apply Increment to DB"):
      cursor.execute("CALL ApplyIncrement(%s)", (global_percent,))
      conn.commit()
  ```

---

### USER STORY 4: Download Filtered Employee Data

**As a user, I should be able to:**

* Export filtered employee data to CSV
* Include: Name, Role, Location, Experience, Compensation, Status
* Include simulated `"New Comp"` if available

#### Streamlit Implementation

* `st.selectbox()` to filter status (Active, Inactive, All)
* Filtered data displayed using `st.dataframe()`
* Export enabled via:

  ```python
  st.download_button("Download CSV", df.to_csv().encode("utf-8"), ...)
  ```

#### 🛠 SQL Integration (Optional)

* Stored Procedure: `CALL GetFilteredData()`

Optional enhancement: use `openpyxl` or `xlsxwriter` to create downloadable Excel with formatting and formulas.

---

```
```


## 5. Screenshots

Place your screenshots in the /screenshots folder and reference them below:

```
![Screenshot 2025-05-17 220823](https://github.com/user-attachments/assets/60fd3575-c985-4b65-a009-ed301677d9ff)
![Screenshot 2025-05-17 220835](https://github.com/user-attachments/assets/c08ca857-9aa1-4474-856f-5c0d369534fd)
![Screenshot 2025-05-17 220703](https://github.com/user-attachments/assets/39d81000-10ee-4177-9151-3f081949df5b)
![Screenshot 2025-05-17 220638](https://github.com/user-attachments/assets/5e423cb8-dafc-4784-8898-34fdcfff6201)
![Screenshot 2025-05-17 220746](https://github.com/user-attachments/assets/9a69888b-df0b-4b4b-846f-2f27a97d39ee)

```

---

### 6. Recommendations 


### 1. Integrate Role-Based Access Control (RBAC)

Why: Different stakeholders (e.g., HR, Managers, Executives) may need different levels of data access and actions (e.g., view only, apply increments, download data).

How:

* Use Streamlit authentication or an external login mechanism (like Firebase Auth or simple login page).
* Set permissions based on roles (e.g., `can_edit`, `can_download`).

---

###  2. Add Dynamic Visualizations for Time-Series Trends

Why: Compensation decisions benefit from historical trends (e.g., past increments, hiring patterns).

How:

* Add a date column for employee joining or increment update.
* Use `st.line_chart()` or `plotly` for trend analysis over months/quarters.
* Optionally filter by date range using `st.date_input()`.

---

###  3. Automate Reporting & Email Integration

Why: Stakeholders may want periodic compensation summaries without logging in.

How:

* Use Python’s `smtplib` or integration tools like SendGrid to schedule emails.
* Convert filtered dashboards to PDF/Excel and send reports automatically.

---




