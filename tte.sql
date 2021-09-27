SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";

CREATE TABLE `tandatanganelektronikqr` (
  `kdtandatanganelektronikqr` bigint(20) UNSIGNED NOT NULL,
  `secret` char(136) DEFAULT NULL,
  `tandatanganelektronikqr` text,
  `checksum` varchar(255) DEFAULT NULL,
  `expired` datetime DEFAULT NULL,
  `lastupdate` datetime DEFAULT NULL,
  `tandatanganelektronikqrawal` text,
  `salt` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

DELIMITER $$
CREATE PROCEDURE `insert_tte` (`pepper_` VARCHAR(255), `tandatanganelektronikqr_` TEXT, `checksum_` VARCHAR(255))  BEGIN
    declare salt_    varchar(255);
    declare secret_  varchar(255);
	set salt_    = `generate_salt`();
	set secret_  = `create_secret`(pepper_, salt_);
	INSERT INTO `tandatanganelektronikqr`
	(`kdtandatanganelektronikqr`,
	`secret`,
	`tandatanganelektronikqr`,
	`checksum`,
	`expired`,
	`lastupdate`,
	`tandatanganelektronikqrawal`,
	`salt`)
	VALUES
	(null,
	secret_,
	tandatanganelektronikqr_,
	checksum_,
	null,
	null,
	null,
	salt_);
    SELECT kdtandatanganelektronikqr FROM tandatanganelektronikqr WHERE secret=secret_ order by kdtandatanganelektronikqr desc limit 0,1;
END$$

CREATE PROCEDURE `select_tte` (`id_` TEXT, `pepper_` VARCHAR(255))  BEGIN
	declare kdtandatanganelektronikqr_ int;
    declare secret8char_ varchar(8);
    set kdtandatanganelektronikqr_ = SUBSTRING_INDEX(SUBSTRING_INDEX(id_, '_', 1), '_', -1) * 1;
    set secret8char_               = SUBSTRING_INDEX(SUBSTRING_INDEX(id_, '_', 2), '_', -1);
	select * from tandatanganelektronikqr where kdtandatanganelektronikqr=kdtandatanganelektronikqr_ and leftpart(secret)=secret8char_ and secret_validation(secret, pepper_, salt);
END$$

CREATE PROCEDURE `simulation` ()  BEGIN
	declare pepper_  varchar(255);
    declare salt_    varchar(255);
    declare secret_  char(136);
    set pepper_  = 'thisispepper';
	set salt_    = `generate_salt`();
	set secret_  = `create_secret`(pepper_, salt_);
    select pepper_ as pepper, salt_ as salt, secret_ as secret, secret_validation(secret_, pepper_, salt_) as validation, right(secret_, 128) as fromsecret, rightpart(secret_, pepper_, salt_) as fromrightpart;
END$$

CREATE FUNCTION `create_secret` (`pepper_` VARCHAR(255), `salt_` VARCHAR(255)) RETURNS CHAR(136) CHARSET latin1 BEGIN
   declare secret_ char(136);
   set secret_ = substring(sha2(concat(to_base64(uuid())), 512), 33, 109);
   RETURN substring(concat(leftpart(secret_), rightpart(secret_, pepper_, salt_)), 1, 136);
END$$

CREATE FUNCTION `generate_salt` () RETURNS VARCHAR(255) CHARSET latin1 BEGIN
	RETURN sha2(to_base64(uuid()), 512);
END$$

CREATE FUNCTION `leftpart` (`secret_` VARCHAR(255)) RETURNS VARCHAR(8) CHARSET latin1 BEGIN
	RETURN left(secret_, 8);
END$$

CREATE FUNCTION `rightpart` (`secret_` VARCHAR(255), `pepper_` VARCHAR(255), `salt_` VARCHAR(255)) RETURNS VARCHAR(128) CHARSET latin1 BEGIN
	declare key_str text;
    declare init_vector blob;
    declare crypt_str text;
    SET block_encryption_mode = 'aes-256-cbc';
	SET key_str = SHA2(_secret_passphrase(),512);
    SET init_vector = _vector();
    SET crypt_str = AES_ENCRYPT(pepper_, key_str, init_vector);
	RETURN sha2(concat(leftpart(secret_), sha2(to_base64(crypt_str), 512), salt_), 512);
END$$

CREATE FUNCTION `secret_validation` (`secret_` CHAR(136), `pepper_` VARCHAR(255), `salt_` VARCHAR(255)) RETURNS TINYINT(1) BEGIN
	RETURN right(secret_, 128) = rightpart(secret_, pepper_, salt_) and secret_ <> '';
END$$

CREATE FUNCTION `url_tte` (`url_` TEXT, `kdtandatanganelektronikqr_` INT) RETURNS TEXT CHARSET latin1 BEGIN
	RETURN concat(url_, ifnull((select concat(kdtandatanganelektronikqr, '_', leftpart(secret)) as id from tandatanganelektronikqr where kdtandatanganelektronikqr=kdtandatanganelektronikqr_), ''));
END$$

CREATE FUNCTION `_secret_passphrase` () RETURNS TEXT CHARSET latin1 NO SQL
begin
    #how to obtain: https://www.avast.com/random-password-generator
    return "~dgIcMk~OoKmXh9S6.$XcispfRlb5KS@(]%@'lI2q1Y+]mMM4NQgvzpJBRwNkKEMZ6254BoSl2z=Vzp_Z^Y^2i6roc#+Ar_v=8Md";
end$$

CREATE FUNCTION `_vector` () RETURNS BLOB NO SQL
begin
	#how to obtain: select random_bytes(16)
	return  0xd70b2ba4509bd51d52ea16b8ab180a36;
end$$

DELIMITER ;

DELIMITER $$
CREATE TRIGGER `bi_tandatanganelektronikqr` BEFORE INSERT ON `tandatanganelektronikqr` FOR EACH ROW BEGIN
	if isnull(new.secret) then
		set new.expired = now();
        set new.tandatanganelektronikqr = '';
    end if;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `bu_tandatanganelektronikqr` BEFORE UPDATE ON `tandatanganelektronikqr` FOR EACH ROW BEGIN
    if isnull(old.secret) then
		set new.expired = now();
        set new.tandatanganelektronikqr = '';
    end if;
    
    if not isnull(old.tandatanganelektronikqr) then
		set new.lastupdate = now();
    end if;
    
    if not isnull(old.tandatanganelektronikqr) and old.tandatanganelektronikqr<>new.tandatanganelektronikqr and isnull(old.tandatanganelektronikqrawal) then
		set new.tandatanganelektronikqrawal = old.tandatanganelektronikqr;
	elseif not isnull(old.tandatanganelektronikqrawal) then
		set new.tandatanganelektronikqrawal = old.tandatanganelektronikqrawal;
	end if;
END
$$
DELIMITER ;

ALTER TABLE `tandatanganelektronikqr`
  ADD PRIMARY KEY (`kdtandatanganelektronikqr`),
  ADD KEY `idx` (`secret`);


ALTER TABLE `tandatanganelektronikqr`
  MODIFY `kdtandatanganelektronikqr` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;