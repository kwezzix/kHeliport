INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_helicopteredealer','Concessionaire Hélicoptère',1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_helicopteredealer','Concessionaire Hélicoptère',1)
;

INSERT INTO `jobs` (name, label) VALUES
	('helicopteredealer','Concessionaire Hélicoptère')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('helicopteredealer',0,'recruit','Recrue',10,'{}','{}'),
	('helicopteredealer',1,'novice','Novice',25,'{}','{}'),
	('helicopteredealer',2,'experienced','Experimente',40,'{}','{}'),
	('helicopteredealer',3,'boss','Patron',0,'{}','{}')
;

CREATE TABLE IF NOT EXISTS `open_helico` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `value` varchar(50) DEFAULT NULL,
  `got` varchar(50) DEFAULT NULL,
  `NB` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=latin1;

CREATE TABLE `owned_helicoptere` (
	`owner` VARCHAR(60) NOT NULL,
	`plate` varchar(12) NOT NULL,
	`vehicle` longtext,
	`type` VARCHAR(20) NOT NULL DEFAULT 'car',
	`job` VARCHAR(20) NULL DEFAULT NULL,
	`stored` TINYINT(1) NOT NULL DEFAULT '0',

	PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `helicoptere_categories` (
	`name` varchar(60) NOT NULL,
	`label` varchar(60) NOT NULL,

	PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `helicoptere_categories` (name, label) VALUES
	('helicoptere','Hélicoptère')
;

CREATE TABLE `helicoptere` (
	`name` varchar(60) NOT NULL,
	`model` varchar(60) NOT NULL,
	`price` int NOT NULL,
	`category` varchar(60) DEFAULT NULL,

	PRIMARY KEY (`model`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `helicoptere` (name, model, price, category) VALUES
	('Akula','akula',500000,'helicoptere'),
	('cargobob','cargobob',500000,'helicoptere'),
	('buzzard','buzzard',500000,'helicoptere'),
	('buzzard2','buzzard2',500000,'helicoptere'),
	('volatus','volatus',500000,'helicoptere'),
	('frogger','frogger',500000,'helicoptere'),
	('supervolito','supervolito',500000,'helicoptere')
;
