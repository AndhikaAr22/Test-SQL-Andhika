CREATE OR REPLACE TABLE `project-bq-satu.testde.report_monthly_orders_product_agg` AS
WITH cte1 AS (
SELECT
  extract(YEAR FROM b.created_at) AS tahun,
  extract(MONTH FROM b.created_at) AS bulan,
  c.id AS produk_id,
  c.name AS nama_produk,
  b.status,
  count(DISTINCT b.order_id) AS total_order,
  sum(a.num_of_item * b.sale_price) AS total_sale
FROM`bigquery-public-data.thelook_ecommerce.orders` a
JOIN `bigquery-public-data.thelook_ecommerce.order_items` b ON a.order_id = b.order_id
JOIN `bigquery-public-data.thelook_ecommerce.products` c ON b.product_id = c.id
WHERE b.status NOT IN ('Cancelled', 'Returned')
GROUP BY 1,2,3,4,5
), cte2 AS(
  SELECT
    nama_produk,
    tahun,
    bulan,
    total_order,
    total_sale,
    ROW_NUMBER() OVER(PARTITION BY tahun, bulan ORDER BY total_sale DESC) AS rnk
  FROM cte1
)
SELECT
  tahun,
  bulan,
  nama_produk,
  total_order,
  total_sale
FROM cte2
WHERE rnk <= 10
ORDER BY 1,2 ;

PENJELASAN:
1. CREATE OR REPLACE TABLE: query ini digunakan untuk membuat atau menggantikan tabel yang sudah ada dengan nama `project-bq-satu.testde.report_monthly_orders_product_agg`
  di dataset testde dalam project project-bq-satu
2. # WITH CTE1 AS: query ini digunakan untuk membuat table sementara 
  # SELECT : query ini untuk memilih beberapa kolom, yaitu tahun,bulan,produk_id,nama_produk, status,total_order,total_sale
  # extract(YEAR FROM b.created_at) AS tahun,extract(MONTH FROM b.created_at) AS bulan : query ini untuk mengambil tahun dan bulan pada kolom created_at
  # c.id AS produk_id, c.name AS nama_produk, b.status : query ini mengambil kolom produk_id dari tabel product, mengambil kolom nama_produk dari tabel products, dan 
  mengambil kolom status dari kolom order_items
  # count(DISTINCT b.order_id) AS total_order : query ini menghitung jumlah pesanan unik untuk setiap produk 
  # sum(a.num_of_item * b.sale_price) AS total_sale : query ini menghitung total penjualan dengan mengalikan kolom num_of_item dengan sale_price
  # FROM`bigquery-public-data.thelook_ecommerce.orders` a : query ini untuk mengambil data dari tabel orders dengan mengaliaskan (a)
  # JOIN `bigquery-public-data.thelook_ecommerce.order_items` b ON a.order_id = b.order_id : query ini untuk menggabungkan tabel orders(a) dengan table order_item(b)
  berdasarkan kolom order_id  disetiap tabelnya
  # JOIN `bigquery-public-data.thelook_ecommerce.products` c ON b.product_id = c.id :query ini untuk menggabungkan tabel order_item(b) dengan table products(c)
  berdasarkan kolom product_id disetiap tabelnya
  # WHERE b.status NOT IN ('Cancelled', 'Returned') : query ini untuk memfilter baris untuk mengecualikan pesanan yang di ('Cancelled', 'Returned')
  # GROUP BY 1,2,3,4,5 : query ini untuk mengelompokan hasil dari kolom-kolom yang dipilih kecuali kolom yang di agregasi, menggunakan nomor agar lebi mudah tanpa
  tanpa harus menuliskan kolom-kolom yang diselect. 1=tahun, 2=bulan,3=produk_id,4=nama_produk,5=status
3. # cte2 AS : membuat tabel sementara yang memproses hasil dari tabel sementara 1(CTE1)
  # SELECT nama_produk, tahun, bulan, total_order, total_sale : query ini untuk memilih kolom-kolom dari tabel sementara 1(CTE1) seperti nama_produk, tahun, bulan, total_order, total_sale
  # ROW_NUMBER() OVER(PARTITION BY tahun, bulan ORDER BY total_sale DESC) AS rnk : queri ini untuk memberikan nomor urut untuk setiap baris dalam grup  berdasarkan
  kolom tahun dan bulan , dengan pengurutan berdasarkan kolom total_sale dalam urutan yang terbesar terlebih dahulu
  # FROM cte1 : query ini untuk mengambil data dari tabel cte1
4. # SELECT tahun,bulan,nama_produk,total_order,total_sale : query ini untuk memilih kolom-kolom dari tabel sementara 2(CTE2) seperti nama_produk, tahun, bulan, total_order, total_sale
  # FROM cte2 : query ini untuk mengambil data dari tabel cte2
  # WHERE rnk <= 10 : query ini untuk memilih produk yang peringkatnya 10 teratas berdasarkan total penjualan untuk setiap bulan dan tahun
  # ORDER BY 1,2 : query ini untuk mengurutkan hasil berdasarkan kolom pertama(tahun) dan kolom kedua(bulan)

NOTE:
pada query diatas ini bertujuan untuk mengahasilkan laporan bulanan produk terbaik berdasarkan jumlah penjualan, lalu memilih 10 teratas untuk setiap bulannya.
lalu menggunakan 2 CTE agar memisahkan perhitungan aggregasi dari perhitungan peringkat, dan memudahkan untuk debugging jika ada masalah dalam query dan
mudah dibaca dan modular