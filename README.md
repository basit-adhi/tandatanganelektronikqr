# tandatanganelektronikqr
Tanda tangan elektronik berbasis QR Code. Verifikasi ke suatu alamat di alamat resmi institusi.

## Instalasi
### Skema (Basis Data)
1. Buat skema dengan user dan password berbeda dengan user skema lain
2. Grant privileges ALL hanya untuk user tersebut ke skema baru tersebut
3. Dump tte.sql
4. Ubah privileges menjadi DELETE,EXECUTE,INDEX,INSERT,'LOCK TABLES',SELECT,UPDATE,TRIGGER
5. Ubah nilai yang ada pada 
	1. *stored procedure* \_secret_passphrase dengan nilai dari https://www.avast.com/random-password-generator
	2. *stored procedure* \_vector dengan nilai dari **select lower(concat("0x", hex(random_bytes(16)))) as new_vector**

### API
1. Salin **\*.php** ke dalam folder yang berbeda dengan folder *web-server* lain, misalnya: /home/user/apitte
2. Atur **open_basedir** ke folder tersebut (https://pdsi.unisayogya.ac.id/move-on-mpm-prefork-ke-mpm-event-sebuah-catatan/#php-n-pool)
3. Ubah nilai yang ada pada **config.php** dan **db.php**
	1. Buat pepper baru menggunakan https://www.avast.com/random-password-generator. Isi **$pepper_** dengan pepper baru tersebut.
	2. Buat password baru kemudian dicatat di suatu tempat. Bcrypt password tersebut. Isi **$pass_** dengan bcrypt dari password baru tersebut.
4. chmod **\*.php** dan **\*.ini** menjadi 0400
5. Apabila terdapat **.htaccess** (tidak disarankan), maka chmod **.htaccess** menjadi 0444 (baca https://pdsi.unisayogya.ac.id/lebih-baik-apache2-conf-daripada-htaccess/)

#### Buat QR Code
```
<?php
$data = [	"pass" => urlencode("$pass_ di config.php sebelum di-bcrypt"), 
		"keterangan" => urlencode("Dokumen ini ditandangani oleh Mr Fulan pada tanggal 1 Januari 2021. Perihal: Surat Kenaikan Tunjangan."), 
		"checksum" => urlencode("")
	];

$ch = curl_init();

curl_setopt($ch, CURLOPT_URL,"https://example.com/create");
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, "ps=".$data["pass"]."&tx=".$data["keterangan"]."&cs=".$data["checksum"]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = json_decode(curl_exec($ch));

curl_close ($ch);

if(is_array($response))
{
	if ($response["status"] == "success")
	{
		//tampilkan url ke dalam bentuk QR Code dan simpan url ke dalam skema (basis data)
		echo '<img src="https://chart.googleapis.com/chart?chs=150x150&cht=qr&chl='.urlencode($response["message"]).'&choe=UTF-8" loading="lazy" />';
	}
}
```
