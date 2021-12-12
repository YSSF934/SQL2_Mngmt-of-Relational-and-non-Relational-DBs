### Data Definition Language (DDL)/*
-This lesson is going to focus on the Data Definition Language (DDL) part of SQL. We'll be looking at the CREATE TABLE and ALTER TABLE commands to help us bring the normalized data schemas from the previous lesson to life in Postgres, one of the most advanced open-source relational database systems out there.
In parallel to that, we'll be learning about the wide variety of data types available in Postgres in order to represent real-life data such as book titles, daily temperatures, dates and times, and more.
While we'll be doing all this work using version 9.6 of Postgres, the commands and types that we learn have been quite stable, and should work exactly the same way in later versions.
-A few things to note:

SQL keywords such as CREATE are case-insensitive, but developers usually prefer to write these keywords using uppercase.
The psql command line doesn't do syntax highlighting, and editing a multi-line command is awkward and error-prone.
To write your SQL more comfortably, you can use a dedicated Postgres GUI such as pgAdmin, or use a text editor with SQL syntax highlighting like Vim or VS Code.

-The complete syntax documentation for CREATE TABLE is available in the Postgres docs. In this lesson, we won't be looking at all the available modifiers of this syntax, preferring instead to only cover the essentials.

My observations from the video:

Multiple values in manager_phones column
Transient dependency between manager_name and emp_id
New: manager_id refers to emp_id
Recursive reference, usual for tree-like structures
So far, we’ve just looked at the normalization issues present, so let’s keep moving.

As the next step, I determined the necessary entities and attributes:

An employees table, with id, emp_name and manager_id
An employee_phones table, with emp_id and phone_number
From there, after also deciding on data types, I can create the actual tables with SQL.

This is the complete SQL solution:

CREATE TABLE "employees" (
  "id" SERIAL,
  "emp_name" TEXT,
  "manager_id" INTEGER
);

CREATE TABLE "employee_phones" (
  "emp_id" INTEGER,
  "phone_number" TEXT
);
*/
#### Numeric Data Types /*
Postgres offers three varieties of integers that vary only by the range of numbers they can represent:

SMALLINT: -32,768 to +32,767
INTEGER: -2,147,483,648 to +2,147,483,647
BIGINT: -9,223,372,036,854,775,808 to +9,223,372,036,854,775,807

When using a SERIAL type, if we don't give it a value when inserting data, Postgres will automatically generate the next integer in sequence,
until the sequence is exhausted based on the range of serial we chose (small, regular, or big).
-Choosing the correct type of integer is crucial. Trying to insert a value larger than the range permitted by our choice will pose an error.
If we find out that we chose the wrong type after our table has millions of data records, rectifying this could require bringing the database down for an extended period of time, as we'll see in later videos on altering table structure.
-Decimals
-What we call a decimal number in normal English numbering is in fact represented by two categories of data types in postgres: exact decimal numbers, and inexact decimal numbers.
-In the last video, we saw that Postgres allows us to move from one data type to another using a process called "casting", which is accomplished using the :: operator. This casting operator is not magical, and will only work in cases where it makes sense.
For example, if we have the text '1.5', we can cast it into an exact numeric value using the notation '1.5'::NUMERIC.

-The inexact types, REAL and DOUBLE PRECISION, which vary only in the range of numbers they can represent, can be used for representing values where each digit may not be crucially significant.
For example, registering a time measurement of 25.154 milliseconds versus 25.155 milliseconds, can in some cases, be acceptable.
-However, if we're trying to measure the world record for the 100 meters sprint, then we might want to have an exact decimal number. Another important field where this exactitude is required is in the world of finance: an interest rate of 2.54% versus one of 2.55% can make a significant difference after it compounds over a long period of time! For these cases, postgres offers the NUMERIC or DECIMAL type, where one can choose the scale, i.e. the number of digits required after the decimal. These numbers will be stored as-is, without any loss of precision.
-The types NUMERIC and DECIMAL are simply two names used to represent exactly the same data type.
USE CASE                              APPROPRIATE NUMBER TYPE
Average daily temperature             REAL
Number of students in a class         SMALLINT
Yearly revenue                        INTEGER
Item price                            NUMERIC
*/
#### Text Data Types /*
Postgres offers two kinds of text data types: fixed-length, and variable length.
-Variable-length data types are VARCHAR(n) — where the limit part, (n), is optional — and TEXT, which offers no limit. Internally, they are stored in exactly the same way, so VARCHAR without limit is the same as TEXT.
The VARCHAR type can also be written as CHARACTER VARYING, and it's exactly the same.
-The fixed-length type is written CHAR(n) or CHARACTER(n). When the (n) limit part is not used, it stores only one character. CHAR is used less often than its variable length counterparts, because it's less agile:
even in cases where you might think that a column will always accept entries of the same length, future business requirements might change, and by then you could have millions of records in a table with a CHAR column, making it lengthy to change the limit.
If you store a value less than the limit, CHAR will pad the remaining characters with spaces to make it the same length.
-Even though TEXT and VARCHAR without limit are the same, you might want to use one over the other as an extremely simplified form of documentation: you might use VARCHAR to represent something unbounded, but that would fit on a single line,
and TEXT to represent large amounts of text like the contents of a book or someone's biography.
-NOTE: Your relational database is often going to be your source of truth, the final resting place of your business' data. As such, even though you're allowed to use unbounded, variable length text fields, you should take great care because these could be abused by users of your applications. Text fields can store hundreds of megabytes of text, and can easily be abused to store data that is not meant to be there. If you don't make verifications at other levels of your application, it would be warranted to add a limit.
You may follow this link to find the full documentation on Postgres Character Types.*/
#### Date/Time datatypes/*
-When you write out a date, e.g. "2018-05-06", you might think of it as a simple string. As such, you might be compelled to use the VARCHAR type in order to store dates and times, and in the vast majority of cases, you'd be making a big oversight!
-Postgres' date and time types are rich, and allow not only to store these values, but also, as we'll see in the next lesson, to manipulate them using a wide array of date/time functions.
-When storing dates and times, it's always important to be mindful of the timezones: both that of your users as well as that of the database server which is storing the data. Postgres handles time zones very elegantly, and allows you to store these values relative to a timezone, or absolutely. Both have their usages./*
-You can check the timezone of a Postgres server by running the SHOW TIMEZONE command, and you can set the timezone of the server by running the SET TIMEZONE command.
-Postgres allows you to store a date/time both with and without a timezone, and they both have their uses.
-If you're scheduling an online meeting between people in different places in the world, you want to make sure they will convene at the same point in time, no matter where they're located!
In this case, you want to make sure that you're storing the timezone shift along with your date/time.
-We’ll come back to the other use case shortly.
-When you store a date/time WITH TIME ZONE, Postgres internally stores the date/time in UTC, but shifts it according to the timezone of the server. This means that even if the time zone of the server changes, Postgres will still have the correct value.
-More precisely, the date/time is stored as a number of milliseconds since the "epoch", which is defined as 1970-01-01 00:00:00-00. This consequently means that the value is stored very efficiently, requiring only an integer.
-If you're a music label, or a gaming company, who wants to release an album or a game on a specific date at 8AM, you usually want that to happen at 8AM for the user.
This means you want to store the release date of your album or game without the timezone shift, thereby saying "8AM local time".
-Postgres provides the values CURRENT_DATE and CURRENT_TIMESTAMP in order to retrieve these current values. You can use these when comparing column values for a SELECT, or when inserting/updating data.
-Follow this link for the full Postgres Date/Time Types.*/
#### Other Data types /*
-Postgres offers many data types that we won't have the time to explore in this course. Here, we've seen an example of that with the JSONB type, which allows us to store composite values inside a single column.
Care should be taken when using this type in order to make sure we don't negate the benefits of normalized data.
Exercise Instructions
Create a schema that can accommodate a hotel reservation system. Your schema should have:

1.  The ability to store customer data: first and last name, an optional phone number, and multiple email addresses.
2.  The ability to store the hotel's rooms: the hotel has twenty floors with twenty rooms on each floor. In addition to the floor and room number, we need to store the room's livable area in square feet.
3.  The ability to store room reservations: we need to know which guest reserved which room, and during what period.
-Here is the first part of my own approach, for customers and customer emails.*/

CREATE TABLE "customers" (
  "id" SERIAL,
  "first_name" VARCHAR,
  "last_name" VARCHAR,
  "phone_number" VARCHAR
);

CREATE TABLE "customer_emails" (
  "customer_id" INTEGER,
  "email_address" VARCHAR
);
/*
-Here is my approach to be able to store the desired room data.*/
CREATE TABLE "rooms" (
  "id" SERIAL,
  "floor" SMALLINT,
  "room_no" SMALLINT,
  "area_sqft" SMALLINT
); /*
And finally, my last piece of the exercise for reservations:*/
CREATE TABLE "reservations" (
  "id" SERIAL,
  "customer_id" INTEGER,
  "room_id" INTEGER,
  "check_in" DATE,
  "check_out" DATE
);
#### Modifying Table structure /*
-Once you've created a table, Postgres offers you the ability to modify its structure using ALTER TABLE. This doesn't remove your responsibility to carefully plan out your data schema!
Modifying a table structure after millions of rows have been inserted could mean having to take your database or your whole application offline.
-In some cases, depending on your situation in terms of volume of data and throughput, another solution might be to create a new table with the structure you need, and migrate the data to it.
This solution isn't without its pitfalls either.
-You may use ALTER TABLE with ADD COLUMN in order to bring in a new column to an already existing table.
-You may use ALTER TABLE with DROP COLUMN to completely remove a column, as well as all the data that was ever stored in all rows for that column. This operation is destructive, and unless you have a database backup, the lost data is unrecoverable!

Follow this link for the full Postgres ALTER TABLE documentation.*/

#### Exercise Instructions/*
Explore the structure of the three tables in the provided SQL workspace. We'd like to make the following changes:

1.  It was found out that email addresses can be longer than 50 characters. We decided to remove the limit on email address lengths to keep things simple.
2.  We'd like the course ratings to be more granular than just integers 0 to 10, also allowing values such as 6.45 or 9.5
3.  We discovered a potential issue with the registrations table that will manifest itself as the number of new students and new courses keeps increasing. Identify the issue and fix it.
-Once again, it’s always important to make sure you fully understand the existing schema before you start making modifications.  Use dt command

1. */
ALTER TABLE "students" ALTER COLUMN "email_address" SET DATA TYPE VARCHAR;/*
2.*/
ALTER TABLE "courses" ALTER COLUMN "rating" SET DATA TYPE REAL;/*
-The main takeaway here is that the data type for numbers is crucial to get right - using the wrong type can destroy part of a desired value.*/

ALTER TABLE "registrations" ALTER COLUMN "student_id" SET DATA TYPE INTEGER;

ALTER TABLE "registrations" ALTER COLUMN "course_id" SET DATA TYPE INTEGER;

#### Other DDL commands/*
-Postgres offers three other DDL commands: DROP, TRUNCATE, and COMMENT.
*   DROP TABLE will completely remove a table's structure and all associated data from the database, and is a destructive operation.
Unless you have a backup, there's no way to recover the lost data!
*   TRUNCATE TABLE keeps the table structure intact, but removes all the data in the table. If you add the optional RESTART IDENTITY to the command,
a SERIAL column's sequence will have its next value reset to 1.  Truncating a table is also a destructive operation, and the data is lost forever unless you have a backup.
*   Finally, the COMMENT command allows you to add a text comment on a table's column. If describing a table using \d table_name, you won't see the comments.
You'd have to use \d+ in order to see the comments that were defined on a table.*/
#### Recap of SQL DDL /*

Here is what we've learned to do in this lesson:

Creating tables with CREATE TABLE
Using Postgres data types to represent real-life data:
  Numbers: INTEGER, SERIAL, REAL, DOUBLE PRECISION, DECIMAL
  Characters: CHARACTER(n), CHARACTER VARYING/VARCHAR, TEXT
  Dates/Times: TIMESTAMP WITH/WITHOUT TIME ZONE, DATE, TIME
There are many data types that we haven't touched, like Geometry, Arrays, ...
How to change table structure using ALTER TABLE to:
  Add/remove columns
  Change the data type of a column
Others DDL commands:
  DROP to remove a table from the database
  TRUNCATE to remove all data in a table
  COMMENT to add a text comment to a table or column
In the next lesson, we'll be looking at the SQL DML to learn how to add, modify, and remove data from Postgres tables.

Follow this link for the full Postgres DDL documentation. Note that some sections of this documentation, like constraints, will be seen in further lessons of this course!*/
#### Glossary /*
Key Term	     Definition
CREATE TABLE	     Allows you to create tables in Postgres.
INTEGER	            A numeric data type that stores numbers without decimals.
SERIAL	           A numeric data type stored as an INTEGER, but that is incremented by one automatically by Postgres each time a new row is added.
REAL	              An inexact numeric data type, with precision to six decimal points.
DOUBLE PRECISION	   An inexact numeric data type, with precision to 15 decimal points.
DECIMAL	            An exact numeric data type that includes decimal values; also known as NUMERIC.
CHARACTER(n)      	Stores text data of length (n). Anything shorter is padded.
VARCHAR	            Stores text of varying data lengths (can be limited by an “n”).
TEXT	              Stores much longer texts of varying data lengths.
TIMESTAMP	           Stores data and time data. Use WITH/WITHOUT TIME ZONE to determine whether a time zone is associated with it (which Postgres updates to match the database’s time zone).
DATE	               Stores date data.
TIME	               Stores time data.
JSONB	              Store more complex data in key-value pairs.
ALTER TABLE	        Change table structure to add/remove columns or change the data type of a column.
DROP	               Remove a table from the database
TRUNCATE            	Remove all data in a table
COMMENT	              Add a text comment to a table or column
