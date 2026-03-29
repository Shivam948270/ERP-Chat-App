create database chatdb;
use chatdb;
create table messages(id int auto_increment primary key,sender varchar(50),receiver varchar(50),message text,created_at timestamp default current_timestamp);