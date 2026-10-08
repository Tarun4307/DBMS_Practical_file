-- =========================================
-- EXPERIMENT: ER DIAGRAM TO RELATIONAL SCHEMA
-- =========================================



-- =========================================
-- 1. CUSTOMER TABLE
-- =========================================

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(15) UNIQUE
);


-- =========================================
-- 2. ADDRESS TABLE
-- =========================================

CREATE TABLE Address (
    AddressID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    HouseNo VARCHAR(50) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    Pincode VARCHAR(10) NOT NULL,

    FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID)
        ON DELETE CASCADE
);


-- =========================================
-- 3. SELLER TABLE
-- =========================================

CREATE TABLE Seller (
    SellerID INT PRIMARY KEY,
    SellerName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE
);


-- =========================================
-- 4. CATEGORY TABLE
-- =========================================

CREATE TABLE Category (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);


-- =========================================
-- 5. PRODUCT TABLE
-- =========================================

CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    CategoryID INT NOT NULL,
    SellerID INT,

    FOREIGN KEY (CategoryID)
        REFERENCES Category(CategoryID)
        ON DELETE CASCADE,

    FOREIGN KEY (SellerID)
        REFERENCES Seller(SellerID)
        ON DELETE SET NULL
);


-- =========================================
-- 6. ORDERS TABLE
-- =========================================

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,

    FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID)
        ON DELETE CASCADE
);


-- =========================================
-- 7. ORDER ITEM TABLE
-- Composite Primary Key
-- =========================================

CREATE TABLE OrderItem (
    OrderID INT,
    ProductID INT,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (OrderID, ProductID),

    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE,

    FOREIGN KEY (ProductID)
        REFERENCES Product(ProductID)
        ON DELETE CASCADE
);


-- =========================================
-- 8. PAYMENT TABLE
-- =========================================

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY,
    OrderID INT NOT NULL UNIQUE,
    PaymentMethod VARCHAR(30) NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE
);


-- =========================================
-- 9. DELIVERY TABLE
-- =========================================

CREATE TABLE Delivery (
    DeliveryID INT PRIMARY KEY,
    OrderID INT NOT NULL UNIQUE,
    AddressID INT,

    DeliveryStatus VARCHAR(30) NOT NULL,

    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE,

    FOREIGN KEY (AddressID)
        REFERENCES Address(AddressID)
        ON DELETE SET NULL
);


-- =========================================
-- INSERT SAMPLE DATA
-- =========================================

-- CUSTOMER
INSERT INTO Customer
VALUES
(1, 'Rahul Sharma', 'rahul@gmail.com', '9876543210'),
(2, 'Aman Verma', 'aman@gmail.com', '9876543211'),
(3, 'Priya Singh', 'priya@gmail.com', '9876543212');


-- ADDRESS
INSERT INTO Address
VALUES
(101, 1, 'House 12', 'Delhi', 'Delhi', '110001'),
(102, 2, 'House 45', 'Chandigarh', 'Punjab', '160001'),
(103, 3, 'House 78', 'Mumbai', 'Maharashtra', '400001');


-- SELLER
INSERT INTO Seller
VALUES
(201, 'Tech World', 'techworld@gmail.com'),
(202, 'Smart Store', 'smartstore@gmail.com');


-- CATEGORY
INSERT INTO Category
VALUES
(301, 'Electronics'),
(302, 'Mobiles'),
(303, 'Laptops');


-- PRODUCT
INSERT INTO Product
VALUES
(401, 'iPhone 15', 69999.00, 302, 201),
(402, 'Samsung Galaxy S24', 64999.00, 302, 202),
(403, 'HP Laptop', 55999.00, 303, 201);


-- ORDERS
INSERT INTO Orders
VALUES
(501, 1, '2026-08-20'),
(502, 2, '2026-08-21');


-- ORDER ITEM
INSERT INTO OrderItem
VALUES
(501, 401, 1, 69999.00),
(501, 403, 1, 55999.00),
(502, 402, 2, 64999.00);


-- PAYMENT
INSERT INTO Payment
VALUES
(601, 501, 'UPI', 125998.00),
(602, 502, 'Credit Card', 129998.00);


-- DELIVERY
INSERT INTO Delivery
VALUES
(701, 501, 101, 'Delivered'),
(702, 502, 102, 'Shipped');


-- =========================================
-- DISPLAY DATA
-- =========================================

SELECT * FROM Customer;
SELECT * FROM Address;
SELECT * FROM Seller;
SELECT * FROM Category;
SELECT * FROM Product;
SELECT * FROM Orders;
SELECT * FROM OrderItem;
SELECT * FROM Payment;
SELECT * FROM Delivery;


-- =========================================
-- REFERENTIAL INTEGRITY VIOLATIONS
-- =========================================

-- VIOLATION 1:
-- CustomerID 99 does not exist
-- This INSERT will be rejected.

INSERT INTO Orders
VALUES
(503, 99, '2026-08-23');


-- VIOLATION 2:
-- ProductID 999 does not exist
-- This INSERT will be rejected.

INSERT INTO OrderItem
VALUES
(501, 999, 1, 5000.00);


-- VIOLATION 3:
-- CategoryID 999 does not exist
-- This INSERT will be rejected.

INSERT INTO Product
VALUES
(404, 'Test Product', 10000.00, 999, 201);


-- VIOLATION 4:
-- Duplicate Email violates UNIQUE constraint

INSERT INTO Customer
VALUES
(4, 'Test User', 'rahul@gmail.com', '9999999999');


-- VIOLATION 5:
-- Duplicate OrderID + ProductID violates composite PRIMARY KEY

INSERT INTO OrderItem
VALUES
(501, 401, 2, 69999.00);


-- =========================================
-- DEMONSTRATE ON DELETE CASCADE
-- =========================================

-- Deleting Customer 1 will also delete:
-- Address belonging to Customer 1
-- Orders belonging to Customer 1
-- OrderItems belonging to those orders
-- Payments and Deliveries belonging to those orders

DELETE FROM Customer
WHERE CustomerID = 1;


-- =========================================
-- DEMONSTRATE ON DELETE SET NULL
-- =========================================

-- Product 401 belongs to Seller 201.
-- After deleting Seller 201, Product 401's
-- SellerID will automatically become NULL.

DELETE FROM Seller
WHERE SellerID = 201;


-- Check the result
SELECT * FROM Product;

-- SellerID of affected products will be NULL.