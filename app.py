import streamlit as st
import pandas as pd
import numpy as np

# --- Load and Clean Data ---
@st.cache_data
def load_data():
    df = pd.read_excel(r"employee_data.xlsx")

    # Strip column names and values
    df.columns = df.columns.str.strip()
    df['Years of Experience'] = df['Years of Experience'].astype(str).str.strip()

    # Clean currency fields
    def clean_currency(col):
        return pd.to_numeric(
            df[col].astype(str)
            .str.replace(',', '', regex=False)
            .str.replace('(', '-', regex=False)
            .str.replace(')', '', regex=False)
            .str.strip(),
            errors='coerce'
        )

    comp_cols = [
        'Current Comp (INR)', 'Industry Compensation', 'Compensation Difference',
        ' Bonus (10%) ', ' Stock Units (12%) ', ' Total Compensation '
    ]
    for col in comp_cols:
        if col in df.columns:
            df[col] = clean_currency(col)

    return df

df = load_data()

# --- UI ---
st.title("💼 Employee Dashboard")

option = st.sidebar.radio("Choose a task", [
    "1️⃣ Filter Active Employees by Role",
    "2️⃣ Group by Years of Experience",
    "3️⃣ Simulate Compensation Increments",
    "4️⃣ Download Filtered Employee Data"
])

# --- User Story 1 ---
if option.startswith("1"):
    st.header("1️⃣ Filter and View Employees")

    roles = df['Role'].dropna().unique()
    selected_roles = st.multiselect("Filter by Role", roles, default=list(roles))

    locations = df['Location'].dropna().unique()
    selected_location = st.selectbox("Select Location for Avg Compensation", locations)

    include_inactive = st.checkbox("Include Inactive Employees (N)", value=False)

    filtered = df[df['Role'].isin(selected_roles)]
    if not include_inactive:
        filtered = filtered[filtered['Active?'] == 'Y']

    st.subheader("Filtered Employee Table")
    st.dataframe(filtered[['Name', 'Role', 'Location', 'Current Comp (INR)']])

    avg_comp = filtered[filtered['Location'] == selected_location]['Current Comp (INR)'].mean()
    st.metric(f"Avg Compensation in {selected_location}", f"₹{avg_comp:,.0f}" if pd.notnull(avg_comp) else "N/A")

    st.subheader("Avg Compensation by Location")
    comp_by_loc = filtered.groupby('Location')['Current Comp (INR)'].mean().sort_values()
    st.bar_chart(comp_by_loc)

# --- User Story 2 ---
elif option.startswith("2"):
    st.header("2️⃣ Group Employees by Experience")

    group_by = st.selectbox("Optional Breakdown by", ["None", "Location", "Role"])

    st.subheader("Employee Count by Experience Range")

    if group_by == "None":
        exp_counts = df['Years of Experience'].value_counts().sort_index()
        st.bar_chart(exp_counts)
    else:
        grouped = df.groupby(['Years of Experience', group_by])['Name'].count().unstack().fillna(0)
        st.bar_chart(grouped)

# --- User Story 3 ---
elif option.startswith("3"):
    st.header("3️⃣ Simulate Compensation Increments")

    increment_mode = st.radio("Increment Mode", ["Global %", "Per Location %", "Per Employee %"])
    df_copy = df.copy()

    if increment_mode == "Global %":
        percent = st.slider("Global Increment (%)", 0, 100, 10)
        df_copy["New Comp (INR)"] = df_copy["Current Comp (INR)"] * (1 + percent / 100)

    elif increment_mode == "Per Location %":
        loc_increments = {}
        for loc in df['Location'].dropna().unique():
            loc_increments[loc] = st.slider(f"{loc} Increment (%)", 0, 100, 10)
        df_copy["New Comp (INR)"] = df_copy.apply(
            lambda row: row["Current Comp (INR)"] * (1 + loc_increments.get(row["Location"], 0) / 100), axis=1
        )

    elif increment_mode == "Per Employee %":
        st.warning("Custom input per employee is not interactive yet. Applying a default value.")
        percent = st.slider("Default Increment (%)", 0, 100, 10)
        df_copy["New Comp (INR)"] = df_copy["Current Comp (INR)"] * (1 + percent / 100)

    st.subheader("Updated Compensation Preview")
    st.dataframe(df_copy[['Name', 'Role', 'Location', 'Current Comp (INR)', 'New Comp (INR)']])

# --- User Story 4 ---
elif option.startswith("4"):
    st.header("4️⃣ Download Filtered Employee Data")

    status = st.selectbox("Filter by Active Status", ["All", "Active Only (Y)", "Inactive Only (N)"])
    export = df.copy()

    if status == "Active Only (Y)":
        export = export[export["Active?"] == "Y"]
    elif status == "Inactive Only (N)":
        export = export[export["Active?"] == "N"]

    export_cols = ["Name", "Role", "Location", "Years of Experience", "Current Comp (INR)", "Active?"]
    if 'New Comp (INR)' in df.columns:
        export_cols.append("New Comp (INR)")

    st.subheader("Data Preview")
    st.dataframe(export[export_cols])

    csv = export[export_cols].to_csv(index=False).encode("utf-8")
    st.download_button("📥 Download CSV", data=csv, file_name="filtered_employees.csv", mime="text/csv")
