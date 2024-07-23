CREATE OR REPLACE TABLE `project-bq-satu.testde.report_monthly_orders_product_agg2` AS
  SELECT
    EXTRACT(YEAR FROM b.created_at) AS tahun,
    EXTRACT(MONTH FROM b.created_at) AS bulan,
    c.id AS produk_id,
    c.name AS nama_produk,
    COUNT(DISTINCT b.order_id) AS total_order,
    SUM(a.num_of_item * b.sale_price) AS total_sale
  FROM `bigquery-public-data.thelook_ecommerce.orders` a
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` b ON a.order_id = b.order_id
  JOIN `bigquery-public-data.thelook_ecommerce.products` c ON b.product_id = c.id
  WHERE b.status NOT IN ('Cancelled', 'Returned')
  GROUP BY tahun, bulan, produk_id, nama_produk
  ORDER BY tahun, bulan, otal_sale DESC


PENJELASAN:
1. CREATE OR REPLACE TABLE: query ini digunakan untuk membuat atau menggantikan tabel yang sudah ada dengan nama `project-bq-satu.testde.report_monthly_orders_product_agg2`
  di dataset testde dalam project project-bq-satu
2.# SELECT : query ini untuk memilih beberapa kolom, yaitu tahun,bulan,produk_id,nama_produk, status,total_order,total_sale
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

NOTE:
pada query diatas ini bertujuan untuk mengahasilkan laporan bulanan produk terbaik berdasarkan jumlah penjualan, lalu diurutkan berdasarkan bulan, tahun
dan total penjualan dari yang terbesar 