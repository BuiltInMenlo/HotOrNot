CREATE TABLE `tblChallengeParticipants` (
  `challenge_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `img` varchar(255) NOT NULL DEFAULT '',
  `joined` int(11) NOT NULL,
  KEY `user_id` (`user_id`),
  KEY `challenge_id` (`challenge_id`),
  CONSTRAINT `tblChallengeParticipants_ibfk_2` FOREIGN KEY (`challenge_id`) REFERENCES `tblChallenges` (`id`),
  CONSTRAINT `tblChallengeParticipants_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `tblUsers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into tblChallengeParticipants ( 
	select c.id, c.challenger_id, c.challenger_img, UNIX_TIMESTAMP( c.updated )
	from tblChallenges as c 
		join tblUsers as u
		on c.challenger_id = u.id
);

CREATE TABLE `tblFlaggedUserApprovals` (
  `challenge_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `flag` tinyint(4) NOT NULL DEFAULT '0',
  `added` int(11) NOT NULL,
  PRIMARY KEY (`challenge_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `tblFlaggedUserApprovals_ibfk_2` FOREIGN KEY (`challenge_id`) REFERENCES `tblChallenges` (`id`),
  CONSTRAINT `tblFlaggedUserApprovals_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `tblUsers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

alter table tblChallenges drop column challenger_id, drop column challenger_img, add column is_verify tinyint not null default 0;
alter table tblUsers add column adid varchar(36) unique null, add column abuse_ct int not null default 0, add column password varchar(100) not null;