import streamlit as st
import pandas as pd

# =====================================================
# CONFIG
# =====================================================

st.set_page_config(
    page_title="Nashville SQL Cleaning Project",
    layout="wide"
)

st.title("🏠 Nashville Housing SQL Cleaning (Step-by-Step Output)")

# =====================================================
# LOAD DATA
# =====================================================

@st.cache_data
def load_data():
    return pd.read_excel('DATA/Nashville Housing Data for Data Cleaning.xlsx')

df = load_data()

# keep working copy
data = df.copy()

# =====================================================
# HELPER
# =====================================================

def show_sql(sql):
    st.subheader("🧾 SQL")
    st.code(sql, language="sql")

def show_result(title, df_show):
    st.subheader("📊 Output")
    st.dataframe(df_show, use_container_width=True)

st.markdown("---")

# =====================================================
# 1. VIEW ORIGINAL DATA
# =====================================================

st.header("1️⃣ Original Dataset")

sql1 = """
SELECT * FROM nashville_housing_cleaned;
"""

show_sql(sql1)
show_result("Original Data", data.head(20))

st.markdown("---")

# =====================================================
# 2. SALE DATE STANDARDIZATION
# =====================================================

st.header("2️⃣ Standardize SaleDate")

sql2 = """
ALTER TABLE nashville_housing_cleaned
ADD datesale DATE;

UPDATE nashville_housing_cleaned
SET datesale = STR_TO_DATE(SaleDate, '%Y-%m-%d');
"""

data["datesale"] = pd.to_datetime(data["SaleDate"], errors="coerce")

show_sql(sql2)
show_result("SaleDate → datesale", data[["SaleDate", "datesale"]].head(20))

st.markdown("---")

# =====================================================
# 3. POPULATE PROPERTY ADDRESS
# =====================================================

st.header("3️⃣ Populate Missing Property Address")

sql3 = """
UPDATE a
JOIN b ON a.ParcelID = b.ParcelID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress IS NULL;
"""

data["PropertyAddress"] = data.groupby("ParcelID")["PropertyAddress"].transform(
    lambda x: x.ffill().bfill()
)

show_sql(sql3)
show_result("Filled Property Address", data[["ParcelID", "PropertyAddress"]].head(20))

st.markdown("---")

# =====================================================
# 4. SPLIT PROPERTY ADDRESS
# =====================================================

st.header("4️⃣ Split Property Address (Street / City / State)")

sql4 = """
ALTER TABLE nashville_housing_cleaned
ADD StreetAddress VARCHAR(255),
ADD City VARCHAR(50),
ADD State VARCHAR(50);
"""

data["StreetAddress"] = data["PropertyAddress"].astype(str).apply(
    lambda x: " ".join(x.split(" ")[:-1])
)

data["City"] = data["PropertyAddress"].astype(str).apply(
    lambda x: x.split(" ")[-1]
)

show_sql(sql4)
show_result("Split Address Output", data[["PropertyAddress", "StreetAddress", "City"]].head(20))

st.markdown("---")

# =====================================================
# 5. SOLD AS VACANT CLEANING
# =====================================================

st.header("5️⃣ SoldAsVacant Standardization")

sql5 = """
UPDATE nashville_housing_cleaned
SET SoldAsVacant =
CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
END;
"""

data["SoldAsVacant"] = data["SoldAsVacant"].replace({
    "Y": "Yes",
    "N": "No"
})

show_sql(sql5)
show_result("SoldAsVacant Cleaned", data["SoldAsVacant"].value_counts().reset_index())

st.markdown("---")

# =====================================================
# 6. REMOVE DUPLICATES
# =====================================================

st.header("6️⃣ Remove Duplicates")

sql6 = """
DELETE FROM nashville_housing_cleaned
WHERE id NOT IN (
    SELECT MIN(id)
    FROM nashville_housing_cleaned
    GROUP BY ParcelID
);
"""

before = data.shape
cleaned = data.drop_duplicates()
after = cleaned.shape

show_sql(sql6)

st.subheader("📊 Output")
st.write("Before:", before)
st.write("After:", after)

st.success("Duplicates removed (preview only)")

st.markdown("---")

# =====================================================
# FINAL DATA PREVIEW
# =====================================================

st.header("✅ Final Cleaned Dataset Preview")

st.dataframe(cleaned.head(30), use_container_width=True)

st.markdown("---")

st.success("🎯 SQL Cleaning Pipeline Completed Successfully")
