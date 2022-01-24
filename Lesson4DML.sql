#### SQL DML: Data Manipulation Language/*
-In this lesson, we'll be learning how to use the SQL DML — Data Manipulation Language — in order to add (INSERT), modify (UPDATE),
and remove (DELETE) data from the database tables we now know how to create.
-While manipulating data, it's often the case that we need to use functions in order to transform that data.
As part of the lesson, we'll be learning about various functions that can act on strings, numbers, and dates.*/
#### Inserting Data: Form One /*
-The first form of the INSERT command we're looking at is: INSERT INTO table (column list) VALUES (first row of values), ....
-When using this form, the column list is optional: if it's not provided, we're saying that we want to assign values to every column of the table, in the order where they're defined.
-When we do include a list of columns, we can decide to skip some columns. If we do, then Postgres will insert the default value assigned to that column in the table definition.
One place where this often happens is for a SERIAL column, where the default value is the next integer in the sequence that was created for that column.
-Inserting values manually in a SERIAL column is perfectly fine by Postgres, since that column is in fact a simple INTEGER with a default value. Postgres won't prevent a SERIAL column from having duplicate values.
 We'll see how to do that in the next lesson by using constraints.
 -We can use the DEFAULT keyword as part of a list of values when inserting new rows of data. This would be the same as skipping the column,
 but can be useful when we want to insert multiple rows with some having the default value and others having a specified value.

Follow this link for the full Postgres INSERT documentation.*/
#### Inserting Data: Form Two/*
-Postgres also allows a second form for inserting data, where we feed the result of a regular SELECT query to the INSERT command. This form is really useful for migrating data from one table to another while transforming it.
-The general way to achieve this is to first use simple SELECTs until we have the data exactly in the form that we want it, then executing a final:
*/
INSERT INTO table_name (column list in the order it's returned by the SELECT) SELECT

-Here is a great example of such a usage: imagine a table of books with an id and title, as well as a category column that is currently in text. The same category can appear multiple times in this table, and we'd want to create a separate categories table with id and name.
We can do the following:

INSERT INTO "categories" ("name") SELECT DISTINCT "category" FROM "books" /*

-The categories table will be filled with all distinct categories from the book table, and each will be assigned a unique ID using the SERIAL column. After that, we can update the books table with a category_id column, something we'll learn how to do in an upcoming video.*/

#### Quiz: Inserting Data in Postgres: Form Two Quiz 2 /*

When would you use INSERT ... VALUES vs. INSERT ... SELECT?

Your reflection
INsert values is for inserting new data.  INsert select is used when taking existing data and migrating it*/

#### Exercise Instructions/*
In this exercise, you'll be asked to migrate a table of denormalized data into two normalized tables. The table called denormalized_people contains a list of people, but there is one problem with it: the emails column can contain multiple emails, violating one of the rules of first normal form.
What more, the primary key of the denormalized_people table is the combination of the first_name and last_name columns. Good thing they're unique for that data set!

In a first step, you'll have to migrate the list of people without their emails into the normalized people table, which contains an id SERIAL column in addition to first_name and last_name.

Once that is done, you'll have to craft an appropriate query to migrate the email addresses of each person to the normalized people_emails table. Note that this table has columns person_id and email, so you'll have to find a way to get the person_id corresponding to the first_name + last_name combination of the denormalized_people table.

Hint #1: You'll need to use the Postgres regexp_split_to_table function to split up the emails
Hint #2: You'll be using INSERT...SELECT queries to achieve the desired result
Hint #3: If you're not certain about your INSERT query, use simple SELECTs until you have the correct output. Then, use that same SELECT inside an INSERT...SELECT query to finalize the exercise.
*/
#### Solution/*
-As usual, it’s important to have first investigated the schema here - as you progress to more and more advanced schemas even outside of the course, you’ll want to know the schema inside and out before making changes.
-The first piece was fairly straightforward in migrating people’s names.*/
-- Migrate people
INSERT INTO "people" ("first_name", "last_name")
  SELECT "first_name", "last_name" FROM "denormalized_people";/*

-The second piece got more advanced, where it’s much more useful to try some SELECT statements to make sure you are grabbing the correct data before making an INSERT. Let’s finish this up below.
-Here is the rest of my solution to this exercise (note my aliasing of “people” as “p” and “denormalized_people” as “dn”, which was just a personal preference):*/
-- Migrate people's emails using the correct ID
INSERT INTO "people_emails"
SELECT
  "p"."id",
  REGEXP_SPLIT_TO_TABLE("dn"."emails", ',')
FROM "denormalized_people" "dn"
JOIN "people" "p" ON (
  "dn"."first_name" = "p"."first_name"
  AND "dn"."last_name" = "p"."last_name"
);

#### updating data in Postgres/*
-The basic syntax for updating data in a table is: UPDATE table_name SET col1=newval1, … WHERE ….
-The WHERE part of the syntax is exactly the same as for a SELECT. Among other things, if you don't include a WHERE clause, you'll be updating all the rows in the table, which is not often what you'd want to do!
-Here, we’ve just covered some basic examples of setting values under a certain condition. For example, to update a table of “users” with columns of “mood” and “happiness_level”, we could update the “mood” where “happiness_level” is less than 33 to ‘Low’:*/
UPDATE “users” SET “mood” = ‘Low’ WHERE “happiness_level” < 33;/*

-Above video, we covered a danger zone for using UPDATE - when a WHERE clause is not included, it will update every single row in the table. There are certainly situations where this might be desired, but usually this is not the case.

-You can also use a sub-select as the value for updating a column, something very powerful! Inside your sub-select, referencing columns from the table you're updating will use the value for the row that's currently being updated.*/
ALTER Table "posts" Add COLUMN "category_id" INTEGER;

UPDATE "posts" SET "category_id"= (
  SELECT "id" FROM "categories" WHERE "categories"."name"="posts"."category");

ALTER Table DROP COLUMN "category";

#### Updating Data in Postgres Quizzes/*

-What command would you use to add 1 to the rating of all movies in the movies table?*/

UPDATE movies SET rating = rating + 1
/*
-What would the result of the following UPDATE be?*/

UPDATE people SET first_name = UPPER(first_name);/*

-this would update all rows becuase theres no WHERE clause in the query */

#### Exercise /*
For this exercise, you're being asked to fix a people table that contains some data annoyances due to the way the data was imported:
1. All values of the last_name column are currently in upper-case. We'd like to change them from e.g. "SMITH" to "Smith".
Using an UPDATE query and the right string function(s), make that happen.*/


-- Update the last_name column to be capitalized
UPDATE "people" SET "last_name" =
  SUBSTR("last_name", 1, 1) ||
  LOWER(SUBSTR("last_name", 2)); /*

-The Postgres SUBSTR function is part of the expansive and powerful set of Postgres String functions.
Postgres allows us to concatenate strings together by using the || operator. The expression 'string1' || 'string2' yields the value 'string1string2'.
 This operator can be chained as many times as needed.

 2. Instead of dates of birth, the table has a column born_ago, a TEXT field of the form e.g. '34 years 5 months 3 days'. We'd like to convert this
  to an actual date of birth. In a first step, use the appropriate DDL command to add a date_of_birth column of the appropriate data type. Then, using an UPDATE query, set the date_of_birth column to the correct value based on the value of the born_ago column.
   Finally, using another DDL command, remove the born_ago column from the table.*/

   -- Change the born_ago column to date_of_birth
   ALTER TABLE "people" ADD column "date_of_birth" DATE;

   UPDATE "people" SET "date_of_birth" =
     (CURRENT_TIMESTAMP - "born_ago"::INTERVAL)::DATE;

   ALTER TABLE "people" DROP COLUMN "born_ago";

#### Deleting Data in POstgres /*
-The basic syntax for deleting rows from a table is DELETE FROM table_name WHERE …. Just like SELECT and UPDATE, omitting the WHERE clause will delete all rows from the table. Again, this is rarely what you want to do! Contrary to TRUNCATE TABLE,
doing a DELETE without a WHERE won't allow you to restart the sequence if you have one in your table. More importantly, in a future lesson we'll learn about indexing as a way to make queries perform faster in the presence of large amounts of data.
Running TRUNCATE will also clear these indexes, which will further accelerate queries once new data gets inserted in that table.

-DELETE is one of the simpler commands because it's not targeting columns. The syntax is straightforward, only requiring the name of the table and, in the majority of cases, the condition for rows to be deleted.

-In the last video, we took advantage of the simplicity of the DELETE syntax to take a look at an unrelated, but sometimes useful Postgres function: pg_typeof. This function receives a value, and returns a string with the type of the value.
This can be useful if you're not certain of the type of an expression. Here, we used it to find out that subtracting two DATEs from each other yields a value of type INTERVAL.*/
#### Quiz/*
Match each case with command

Removing a table from the system        DROP

Removing all data from a table          TRUNCATE

Removing some data from a table         DELETE

Removing a column from a table          ALTER*/

#### Data Manipulation: Transactions/*
-So far, we've learned how to manipulate data in our database, and we've done it by sending single, one-off commands to our database. Many real-life situations require multiple manipulations to be orchestrated in order to achieve the desired result.
-The classic example of that is a bank transfer, which, incidentally, is called a transaction. In a bank transfer, we first need to remove money from one account, then we need to add money to another account. You can imagine that this would be done using two UPDATE commands.
In this case, it's crucial to have certainty that these two updates will run successfully:
if the database server were to crash between the two updates, it could leave our database in an inconsistent state.

 -To help with these kinds of situations, Postgres and other relational databases provide transactional guarantees that can be remembered under the acronym ACID. They are:

Atomicity: The database guarantees that a transaction will either register all the commands in a transaction, or none of them.
Consistency: The database guarantees that a successful transaction will leave the data in a consistent state, one that obeys all the rules that you've setup. We've seen simple rules like limiting the number of characters in a VARCHAR column, and we'll see many more in the next lesson
Isolation: The database guarantees that concurrent transactions don't "see each other" until they are committed. Committing a transaction is a command that tells the database to execute all the commands we passed to it since we started that transaction.
Durability: The database guarantees that once it accepts a transaction and returns a success, the changes introduced by the transaction will be permanently stored on disk, even if the database crashes right after the success response.

-A large portion of interactions with a database don't happen with a human using the psql command line, but instead through application code. When interacting with Postgres through its command line, a feature called AUTOCOMMIT is automatically enabled. This feature makes it so that every command you run is wrapped in a transaction.
It's possible to turn off this feature by executing \set AUTOCOMMIT off from the psql command line.
-In the case where AUTOCOMMIT is off, or in the case where the database is being interacted with through application code, starting a transaction is achieved using the START TRANSACTION or BEGIN commands, which are equivalent. Any commands executed after this will be run in isolation from any other transactions.
If the application — or the psql program — crashes at any point, all the commands will be discarded. We can also manually discard all the commands executed after starting a transaction by running ROLLBACK. In order to make the changes permanent, one has to execute the command COMMIT or END, which are equivalent.
-We can observe the isolation property of transactions by running two psql sessions and issuing commands with AUTOCOMMIT set to off. Doing so, we'll see that the commands executed in one session don't affect the data seen in the other session until we run COMMIT.
-We can observe the consistency property of transactions by starting one manually in psql, and provoking an error after executing a successful DML query. If trying to commit the semi-failed transaction, Postgres will reply with ROLLBACK: it will refuse to execute the whole transaction because an error happened at some point during it,
thereby preserving the consistency of our data.
-If you are exploring a new database that you're not familiar with and would like to see the effect of running some DML queries, make sure that you \set AUTOCOMMIT off before. You'll be in a much safer position, and any mistakes you make can be manually rolled back using the ROLLBACK command.
-In the context of interacting with Postgres through an application layer, we can do the same thing: if the application detects an error condition in the middle of a transaction, it can issue a ROLLBACK to abort the whole transaction, and return an error to the user.
*/
#### Data Manipulation Exercise/*
-For this exercise, you'll be given a table called user_data, and asked to make some changes to it. In order to make sure that your changes happen coherently, you're asked to turn off auto-commit, and create your own transaction around all the queries you will run.

Here are the changes you will need to make:
1.  Due to some obscure privacy regulations, all users from California and New York must be removed from the data set.
2.  For the remaining users, we want to split up the name column into two new columns: first_name and last_name.
3.  Finally, we want to simplify the data by changing the state column to a state_id column.
      A.  First create a states table with an automatically generated id and state abbreviation.
      B.   Then, migrate all the states from the dataset to that table, taking care to not have duplicates.
      C.  Once all the states are migrated and have their unique ID, add a state_id column to the user_data table.
      D.  Use the appropriate query to make the state_id of the user_data column match the appropriate ID from the new states table.
      E.  Remove the now redundant state column from the user_data table.

-Here is the full solution to this exercise:*/
-- Do everything in a transaction
BEGIN;


-- Remove all users from New York and California
DELETE FROM "user_data" WHERE "state" IN ('NY', 'CA');


-- Split the name column in first_name and last_name
ALTER TABLE "user_data"
  ADD COLUMN "first_name" VARCHAR,
  ADD COLUMN "last_name" VARCHAR;

UPDATE "user_data" SET
  "first_name" = SPLIT_PART("name", ' ', 1),
  "last_name" = SPLIT_PART("name", ' ', 2);

ALTER TABLE "user_data" DROP COLUMN "name";


-- Change from state to state_id
CREATE TABLE "states" (
  "id" SMALLSERIAL,
  "state" CHAR(2)
);

INSERT INTO "states" ("state")
  SELECT DISTINCT "state" FROM "user_data";

ALTER TABLE "user_data" ADD COLUMN "state_id" SMALLINT;

UPDATE "user_data" SET "state_id" = (
  SELECT "s"."id"
  FROM "states" "s"
  WHERE "s"."state" = "user_data"."state"
);

ALTER TABLE "user_data" DROP COLUMN "state";

#### Data Manipulation Recap/*

In this lesson, you:

Delved deeper into designing proper, normalized relational schemas
Created and modified table structures
Added, modified and deleted data from tables with INSERT, UPDATE and DELETE
Learned to use ACID Transactions*/
#### Glossary/*

Key Term	               Definition
INSERT ... VALUES     	One form of adding data into a table; used when introducing new data in a table. This data would come from an external source like an application.
INSERT ... SELECT	      One form of adding data into a table; used when taking already existing data from a table and migrating it — most often with some modifications or clean-ups — into an already existing table.
UPDATE	                Used to update rows of data within a given column with new values.
DELETE	                Used to delete some portion of data from a table.
BEGIN	                  Starts a transaction.
COMMIT	                Tells the system to attempt to complete the transaction (make the requested changes). Similar functionality is also achieved with END.
ROLLBACK	              Tells the system to not commit any changes as part of the current transaction, discarding the changes.
ACID	                  An acronym that describes the transactional guarantees provided by a relational database.
Atomicity	              The database guarantees that a transaction will either register all the commands in a transaction, or none of them.
Consistency	            The database guarantees that a successful transaction will leave the data in a consistent state, one that obeys all the rules that you've setup. We've seen simple rules like limiting the number of characters in a VARCHAR column, and we'll see many more in the next lesson.
Isolation	              The database guarantees that concurrent transactions don't "see each other" until they are committed. Committing a transaction is a command that tells the database to execute all the commands we passed to it since we started that transaction.
Durability	            The database guarantees that once it accepts a transaction and returns a success, the changes introduced by the transaction will be permanently stored on disk, even if the database crashes right after the success response.
