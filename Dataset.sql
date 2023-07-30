drop table if exists product_hierarchy
CREATE TABLE product_hierarchy (
  "id" INTEGER,
  "parent_id" INTEGER,
  "level_text" VARCHAR(19),
  "level_name" VARCHAR(8)
);

INSERT INTO product_hierarchy
  ("id", "parent_id", "level_text", "level_name")
VALUES
  ('1', NULL, 'Women', 'Category'),
  ('2', NULL, 'Men', 'Category'),
  ('3', '1', 'Jeans', 'Segment'),
  ('4', '1', 'Jacket', 'Segment'),
  ('5', '2', 'Shirt', 'Segment'),
  ('6', '2', 'Socks', 'Segment'),
  ('7', '3', 'Navy Oversized', 'Style'),
  ('8', '3', 'Black Straight', 'Style'),
  ('9', '3', 'Cream Relaxed', 'Style'),
  ('10', '4', 'Khaki Suit', 'Style'),
  ('11', '4', 'Indigo Rain', 'Style'),
  ('12', '4', 'Grey Fashion', 'Style'),
  ('13', '5', 'White Tee', 'Style'),
  ('14', '5', 'Teal Button Up', 'Style'),
  ('15', '5', 'Blue Polo', 'Style'),
  ('16', '6', 'Navy Solid', 'Style'),
  ('17', '6', 'White Striped', 'Style'),
  ('18', '6', 'Pink Fluro Polkadot', 'Style');

drop table if exists product_prices
CREATE TABLE product_prices (
  "id" INTEGER,
  "product_id" VARCHAR(6),
  "price" INTEGER
);

INSERT INTO product_prices
  ("id", "product_id", "price")
VALUES
  ('7', 'c4a632', '13'),
  ('8', 'e83aa3', '32'),
  ('9', 'e31d39', '10'),
  ('10', 'd5e9a6', '23'),
  ('11', '72f5d4', '19'),
  ('12', '9ec847', '54'),
  ('13', '5d267b', '40'),
  ('14', 'c8d436', '10'),
  ('15', '2a2353', '57'),
  ('16', 'f084eb', '36'),
  ('17', 'b9a74d', '17'),
  ('18', '2feb6b', '29');

drop table if exists product_details
CREATE TABLE product_details (
  "product_id" VARCHAR(6),
  "price" INTEGER,
  "product_name" VARCHAR(32),
  "category_id" INTEGER,
  "segment_id" INTEGER,
  "style_id" INTEGER,
  "category_name" VARCHAR(6),
  "segment_name" VARCHAR(6),
  "style_name" VARCHAR(19)
);

INSERT INTO product_details
  ("product_id", "price", "product_name", "category_id", "segment_id", "style_id", "category_name", "segment_name", "style_name")
VALUES
  ('c4a632', '13', 'Navy Oversized Jeans - Women', '1', '3', '7', 'Women', 'Jeans', 'Navy Oversized'),
  ('e83aa3', '32', 'Black Straight Jeans - Women', '1', '3', '8', 'Women', 'Jeans', 'Black Straight'),
  ('e31d39', '10', 'Cream Relaxed Jeans - Women', '1', '3', '9', 'Women', 'Jeans', 'Cream Relaxed'),
  ('d5e9a6', '23', 'Khaki Suit Jacket - Women', '1', '4', '10', 'Women', 'Jacket', 'Khaki Suit'),
  ('72f5d4', '19', 'Indigo Rain Jacket - Women', '1', '4', '11', 'Women', 'Jacket', 'Indigo Rain'),
  ('9ec847', '54', 'Grey Fashion Jacket - Women', '1', '4', '12', 'Women', 'Jacket', 'Grey Fashion'),
  ('5d267b', '40', 'White Tee Shirt - Men', '2', '5', '13', 'Mens', 'Shirt', 'White Tee'),
  ('c8d436', '10', 'Teal Button Up Shirt - Men', '2', '5', '14', 'Men', 'Shirt', 'Teal Button Up'),
  ('2a2353', '57', 'Blue Polo Shirt - Men', '2', '5', '15', 'Men', 'Shirt', 'Blue Polo'),
  ('f084eb', '36', 'Navy Solid Socks - Men', '2', '6', '16', 'Men', 'Socks', 'Navy Solid'),
  ('b9a74d', '17', 'White Striped Socks - Men', '2', '6', '17', 'Men', 'Socks', 'White Striped'),
  ('2feb6b', '29', 'Pink Fluro Polkadot Socks - Men', '2', '6', '18', 'Men', 'Socks', 'Pink Fluro Polkadot');

-- Please download product_sales file for sales data
------------------------------------------------------------------------
