-- create tabel analisa
CREATE TABLE dataset_kf_finaltask.kf_tb_analisa AS
SELECT 
    ft.transaction_id, 
    ft.date, 
    ft.branch_id, 
    kc.branch_name, 
    kc.kota, 
    kc.provinsi, 
    kc.rating as rating_cabang, 
    ft.customer_name, 
    ft.product_id, 
    pro.product_name, 
    pro.price as actual_price, 
    ft.discount_percentage,
    CASE
        WHEN ft.price <= 50000 THEN 0.1
        WHEN ft.price > 50000 AND ft.price <= 100000 THEN 0.15
        WHEN ft.price > 100000 AND ft.price <= 300000 THEN 0.2
        WHEN ft.price > 300000 AND ft.price <= 500000 THEN 0.25
        WHEN ft.price > 500000 THEN 0.3
        ELSE 0
    END AS persentase_gross_laba,
    ft.price * (1 - ft.discount_percentage) as nett_sales,
    (
        SELECT 
            SUM(pro.price) - SUM(pro.price * ft.discount_percentage)
        FROM 
            dataset_kf_finaltask.kf_final_transaction AS ft
        JOIN 
            dataset_kf_finaltask.kf_product AS pro ON ft.product_id = pro.product_id
    ) AS nett_profit,
    ft.rating AS rating_transaksi
FROM 
    dataset_kf_finaltask.kf_final_transaction AS ft
LEFT JOIN 
    dataset_kf_finaltask.kf_kantor_cabang AS kc ON ft.branch_id = kc.branch_id
LEFT JOIN 
    dataset_kf_finaltask.kf_product AS pro ON ft.product_id = pro.product_id
;


-- create tabel perbandingan pendapatan tiap tahun
CREATE TABLE dataset_kf_finaltask.kf_perbandingan_pendapatan AS
SELECT 
    EXTRACT(YEAR FROM date) AS tahun,
    SUM(CASE WHEN EXTRACT(YEAR FROM date) = 2020 THEN price ELSE 0 END) AS pendapatan_2020,
    SUM(CASE WHEN EXTRACT(YEAR FROM date) = 2021 THEN price ELSE 0 END) AS pendapatan_2021,
    SUM(CASE WHEN EXTRACT(YEAR FROM date) = 2022 THEN price ELSE 0 END) AS pendapatan_2022,
    SUM(CASE WHEN EXTRACT(YEAR FROM date) = 2023 THEN price ELSE 0 END) AS pendapatan_2023
FROM 
    dataset_kf_finaltask.kf_final_transaction
WHERE 
    EXTRACT(YEAR FROM date) BETWEEN 2020 AND 2023
GROUP BY 
    EXTRACT(YEAR FROM date)
ORDER BY 
    tahun;

-- create tabel top 10 total transaksi cabang provinsi
SELECT 
    COUNT(ft.transaction_id) AS total_transaksi,
    kc.provinsi
FROM 
    dataset_kf_finaltask.kf_final_transaction AS ft
LEFT JOIN 
    dataset_kf_finaltask.kf_kantor_cabang AS kc ON ft.branch_id = kc.branch_id
GROUP BY 
    kc.provinsi
ORDER BY 
    total_transaksi DESC
LIMIT 10;

-- Create tabel top 10  nett sales cabang provinsi
SELECT 
    SUM(anls.nett_sales) AS nett_sales,
    kc.provinsi
FROM 
    dataset_kf_finaltask.kf_tb_analisa AS anls
LEFT JOIN 
    dataset_kf_finaltask.kf_kantor_cabang AS kc ON anls.branch_id = kc.branch_id
GROUP BY 
    kc.provinsi
ORDER BY 
    nett_sales DESC
LIMIT 10;
