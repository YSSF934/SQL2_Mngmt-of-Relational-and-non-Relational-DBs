#### Introduction to Consistency /*
-A relational database will often be the final resting place of your business' data. You'll hear it referred to as the "source of truth", a place where you can always go to get accurate information about your customers and business activities.
-As such, it's extremely important that the data in your relational database be kept consistent, and valid. We've already seen simple examples of adding rules to Postgres: for example, if your company's employee identification numbers are always 10 characters,
 you can set the column for that piece of data to VARCHAR(10) — or even CHAR(10) — and Postgres will enforce that limit.
 -Often, you'll need to enforce rules that are more complex that can be described by a data type. An example of this is enforcing that an INTEGER column contains only positive numbers. Yet another example is enforcing that an author_id INTEGER column in a books
 table refers to valid values of id that are actually present in the related authors table, and not contain "just integers".
 -In this lesson we'll see how to enforce these kinds of rules and more at the level of the database.*/
 #### The Big Picture on Consistency/*
 -In this video, we zoomed out to take a look at the movement of data, and how it is related to validations and consistency. Data doesn't just "get to your database": it has to come from somewhere. Whether it's being imported from a CSV file, typed in manually by an operator,
 or introduced through application code running on another server, a path was followed.
 -Let's follow the path of a common piece of data: user registration information. Picture yourself on a new web application you're trying to register to. When introducing your username, the app would have some rules such as "the username must be at least five characters".
 As you type your username, this user-facing web application might do its own validation, and give you immediate feedback if you break those rules
 -Once you submit the registration form, that data will move from your browser to an API server, using the data format that the API server expects. There, the server has no idea that the data came from that web form: it could have come from anywhere.
This API server cannot trust that the data has already been validated, and will do its own, "server-side" validation. If the server is satisfied with its validation, it will then send the data to a database to be stored durably and indefinitely.
-Once the database received the request to store that user data, the same story repeats: even though there might be an implicit trust between the database server and the API server, since they're both controlled by the same entity, the database has no way of knowing that the
 data came from the API server and not from another place like a human operator or a CSV import. It follows that the database will have to do its own validation. Since that database is the "source of truth" of the business' data, this validation is crucial.
 -In this lesson, we'll take a look at the different mechanisms that Postgres makes available to us in order to validate data and keep it consistent.
 Quiz
 -In which of the following situations would you use a database's consistency rules?
 a.  To Make sure an integer column has strictly positive numbers
 b.  TO make sure a username VARCHAR column contains unique VALUES*/
 #### Unique constraints/*
 -A unique constraint is a type of rule that you can add to a database table to ensure that a column or set of columns are unique across all the rows of the table. A common use-case for that is ensuring that no two users of your system can register with the same username.
 -When adding a unique constraint to a table, you can choose to give it a name or not. If you don't, Postgres will automatically generate a name for the constraint. Providing your own name for the constraint is a great and simple way to document what business rule this constraint is enforcing.
 -Unique constraints can target multiple columns. In that case, it's the combination of columns that has to be unique across the table.
 -Follow this link at section 5.3.3 for the full Postgres Unique Constraints documentation. https://www.postgresql.org/docs/9.6/ddl-constraints.html
 Quiz
 -What is the correct syntax for making the users table username column unique while giving it a custom name?*/
      ALTER Table "users" ADD CONSTRAINT
      "unique_usernames" UNIQUE ("username")

#### Primary Key constraints/*
-A primary key constraint is a special type of unique constraint: just like a unique constraint, it enforces unique values across a column or set of columns. In addition to that, it also enforces a NOT NULL, which is another database constraint that can be used by itself to ensure that a column's values cannot be null.
 -In fact, a unique constraint cannot deduplicate between NULL values, because the special NULL value is not even equal to itself! This means that having a unique constraint on a column will still allow multiple rows of data to have the value NULL for that column. Sometimes, that's exactly what you need.
 -Another difference between a unique and primary key constraint is that there can only be one primary key constraint per table: this primary key constraint is going to identify the column or set of columns that will be the "official" database identifier for rows in that table.
 -While a SERIAL type of column can automatically generate incrementing integer values, only defining a column as SERIAL doesn't guarantee uniqueness of the values, since values can be specified manually. Adding a UNIQUE constraint could be thought of as being sufficient, but that would allow NULL values.
 -While the combination UNIQUE NOT NULL has the same effect in terms of constraints as PRIMARY KEY, we'll want to have a primary key constraint on most of our tables: this will be the special unique key that identifies rows in that table.
 -Often, a good choice is to have a so-called "surrogate key", that is, a key that is artificially generated, and that appears nowhere in the business requirements or verbiage. This will allow us to relate different entities together without relying on a piece of business data whose rules might change in the future.
 In opposition to a surrogate key, a key using a value that is part of the actual data is called a "natural key".
 Quiz
 1. What are the differences between a unique constraint and a primary key constraint?
  -Only Primary Key Constraints disallows NULL's
*/
#### Unique and Primary constraints Exercise Instructions/*
-For this exercise, you're going to have to explore the data schema in the Postgres workspace in order to determine which pieces of data require Unique and Primary Key constraints.
Then, you'll have to execute the appropriate ALTER TABLE statements to add these constraints to the data set.
Hint: There are 6 total constraints to be added.*/
#### Unique & Primary Key Constraints Exercise: Solution/*
-Remember: as a first step when confronted with a new database or dataset, always use all the introspection commands available to you — \d, \dt, \d+ — to observe and analyze the data before doing anything else.

Solution
*/
ALTER TABLE "books" ADD PRIMARY KEY ("id");

ALTER TABLE "books" ADD UNIQUE ("isbn");

ALTER TABLE "authors" ADD PRIMARY KEY ("id");

ALTER TABLE "authors" ADD UNIQUE ("email_address");

ALTER TABLE "book_authors" ADD PRIMARY KEY ("book_id", "author_id");

ALTER TABLE "book_authors" ADD UNIQUE ("book_id", "contribution_rank");
