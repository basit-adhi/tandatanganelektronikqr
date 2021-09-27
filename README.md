# tandatanganelektronikqr
Tanda tangan elektronik berbasis QR Code. Verifikasi ke suatu alamat di alamat resmi institusi.

## Instalasi
### Skema (Basis Data)
1. Buat skema dengan user dan password berbeda dengan user skema lain
2. Grant privileges ALL hanya untuk user tersebut ke skema baru tersebut
3. Dump tte.sql
4. Ubah privileges menjadi DELETE,EXECUTE,INDEX,INSERT,'LOCK TABLES',SELECT,UPDATE,TRIGGER

### API
1. Salin **\*.php** ke dalam folder yang berbeda dengan folder *web-server* lain, misalnya: /home/user/apitte
2. Atur **open_basedir** ke folder tersebut (https://pdsi.unisayogya.ac.id/move-on-mpm-prefork-ke-mpm-event-sebuah-catatan/#php-n-pool)
3. Ubah nilai yang ada pada **config.php** dan **db.php**
	1. Buat pepper baru menggunakan https://www.avast.com/random-password-generator. Isi **$pepper_** dengan pepper baru tersebut.
	2. Buat password baru kemudian dicatat di suatu tempat. Bcrypt password tersebut. Isi **$pass_** dengan bcrypt dari password baru tersebut.
4. chmod **\*.php** dan **\*.ini** menjadi 0400
5. Apabila terdapat **.htaccess** (tidak disarankan), maka chmod **.htaccess** menjadi 0444 (baca https://pdsi.unisayogya.ac.id/lebih-baik-apache2-conf-daripada-htaccess/)
