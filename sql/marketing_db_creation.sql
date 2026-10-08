CREATE DATABASE IF NOT EXISTS marketing_db;
USE marketing_db;

CREATE TABLE customers (
    customer_id     INT PRIMARY KEY,
    year_birth      SMALLINT,
    age_enrolled    TINYINT,
    education       VARCHAR(20),
    marital_status  VARCHAR(20),
    income          DECIMAL(10,2),
    kidhome         TINYINT,
    teenhome        TINYINT,
    dt_customer     DATE,
    recency         SMALLINT,
    complain        TINYINT
);


CREATE TABLE campaigns(
campaign_id INT PRIMARY KEY,
campaign_name VARCHAR(20),
cost_per_contact DECIMAL(10,2),
revenue_per_response DECIMAL(10,2)
);


CREATE TABLE channels(
channel_id INT PRIMARY KEY,
channel_name VARCHAR(20)
);


CREATE TABLE responses (
    customer_id  INT,
    campaign_id  INT,
    accepted     TINYINT,
    PRIMARY KEY (customer_id, campaign_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);



CREATE TABLE purchases (
    customer_id    INT,
    channel_id     INT,
    num_purchases  INT,
    PRIMARY KEY (customer_id, channel_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (channel_id) REFERENCES channels(channel_id)
);

SHOW TABLES;
