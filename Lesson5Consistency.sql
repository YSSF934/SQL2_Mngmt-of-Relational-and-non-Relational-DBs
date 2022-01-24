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

#### Foreign Key Constraints/*
-Foreign key constraints will restrict the values in a column to only values that appear in another column. They're often used to relate IDs in relationships between tables, thereby preserving what we call "referential integrity".
 In many cases, the foreign key will refer to a primary key in another table, but that is not necessary. Any column can be referenced by a foreign key constraint.

-We can add foreign key constraints while creating a table, either by adding a REFERENCES clause with the column definition, or by adding a CONSTRAINT … FOREIGN KEY clause along with all the column definitions.

The basic syntax would be:*/

FOREIGN KEY "referencing_column"
REFERENCES "referenced_table" ("referenced_column")/*

-If we omit the ("referenced_column") part of the foreign key definition, then it will be implied that we are referencing the primary key of the referenced table. This is one more thing that makes primary key constraints special compared to unique constraints.

QUIZ
What is the goal of a foreign key constraint?
a.  Ensure that values in a column are present in another column*/

#### Foreign Key Constraints: Modifiers/*
-Once we set up a foreign key constraint, the database will enforce it from all angles. For example, if we have a comments table with a user_id column, and insert a new comment with a valid user ID, we shouldn't be able to delete the referenced user. But what if we wanted to do that?
-For example, in the comment example, our business rules might state that "if a user deletes their account, then we want to keep all their comments, but simply dissociate them from the now deleted user".
In practice, we could achieve that by setting the user_id column of the comments table to NULL everywhere where the value was the now deleted user account's ID.
-In that same system, we could have another business rule that relates posts to comments saying that "when a post gets deleted, we will also delete any comments that were created for that post".
In practice, we could do that in two steps by first deleting all the comments targeting the post_id we want to delete, then deleting the post itself.
-With foreign key constraints, we can add modifiers when specifying the constraint that will take care of these two use-cases automatically for us.

Adding*/ ON DELETE CASCADE/* to a foreign key constraint will have the effect that when the referenced data gets deleted, the referencing rows of data will be automatically deleted as well.

Adding*/ ON DELETE SET NULL/* to a foreign key constraint will have the effect that when the referenced data gets deleted, the referring column will have its value set to NULL. Since NULL is a special value, it won't break the foreign key constraint because it will be clear that that row of data is now referencing absolutely nothing.

Follow this link at section 5.3.5 for the Postgres foreign key constraints documentation. https://www.postgresql.org/docs/9.6/ddl-constraints.html

Quiz
Given a table books with id, title, and author_id which references the id column of another table called authors, what is the proper syntax to add a foreign key constraint that will make sure that all books belonging to an author get deleted if the author gets deleted?

ALTER TABLE "books"
ADD FOREIGN KEY "author_id"
REFERENCES "authors ("id") ON DELETE CASCADE;

#### Exercise: Foreign Key Constraints

Exercise Instructions
For this exercise, you're going to add some foreign key constraints to an existing schema, but you'll have to respect some business rules that were put in place:

1.  As a first step, please explore the currently provided schema and understand the relationships between all the tables

2.  Once that's done, please create all the foreign key constraints that are necessary to keep the referential integrity of the schema, with the following in mind:
      A.  When an employee who's a manager gets deleted from the system, we want to keep all the employees that were under him/her. They simply won't have a manager assigned to them.
      B.  We can't delete an employee as long as they have projects assigned to them
      C.  When a project gets deleted from the system, we won't need to keep track of the people who were working on it.

#### Foreign Key Constraints Exercise Solution
-Contrary to the exercise you were given, in practice business requirements will rarely tell you that "things have to be consistent": that's something that is implied. However, in the context of foreign keys, business requirements often hint at how you should set up these constraints,
in terms of what should happen to referencing data when referenced data gets modified or deleted.

Here is the full solution to the exercise you were given:
*/
ALTER TABLE "employees"
  ADD CONSTRAINT "valid_manager"
  FOREIGN KEY ("manager_id") REFERENCES "employees" ("id") ON DELETE SET NULL;

ALTER TABLE "employee_projects"
  ADD CONSTRAINT "valid_employee"
  FOREIGN KEY ("employee_id") REFERENCES "employees" ("id");

ALTER TABLE "employee_projects"
  ADD CONSTRAINT "valid_project"
  FOREIGN KEY ("project_id") REFERENCES "projects" ("id") ON DELETE CASCADE; /*

*/ #### Check Constraints
/*
-CHECK constraints allow us to implement custom business rules at the level of the database. Examples of such rules would be: "a product can't have a negative quantity" or "the discount price should always be less than the regular price".

-A CHECK constraint can be added either after a table was created, or during table creation. Like all other constraints, it can be added along with the column definition, or along with all the column definitions.

-The general syntax of the constraint is: CHECK (some expression that returns true or false). The expression can target one column, multiple columns, and use any Postgres functions to do its checking.
-Follow this link at section 5.3.1 for the full Postgres check constraints documentation. https://www.postgresql.org/docs/9.6/ddl-constraints.html
*/
#### Check Constraints Quizzes/*
1.  What's the correct syntax for making the already existing column quantity of the items table only accept integers that are strictly larger than zero?*/
ALTER TABLE "items"
Check ("quantity" > 0 )
/*
Check Constraints Hard Quiz
Given a table users with a date_of_birth column of type DATE, write the SQL to add a requirement for users to be at least 18 years old.*/

ALTER TABLE "users"
  ADD CONSTRAINT "users_must_be_over_18" CHECK (
    CURRENT_TIMESTAMP - "date_of_birth" > INTERVAL '18 years'
  );

#### Constraints Review: Final review/*

In this lesson, we've looked at database constraints as a way to make data more consistent and in line with business requirements. We've seen:

  * Unique constraints, which prevent duplicate values for a given column or columns, except for NULL which is allowed to appear many times.
  * Not null constraints, which prevent a column from containing the value NULL.
  * Primary key constraints, which, in addition to being a combination of Unique and Not Null constraints, are special: there can only be one per table, it's the official column or set of columns to uniquely identify a row in that table, and it's the default column(s) that will be used when setting up a foreign key constraint referencing that table.
  * Foreign key constraints, which restrict values in a column to only those values present in another column. They maintain what we called "referential integrity".
  * Check constraints, which can be used to implement custom checks against data that gets added or modified in our tables.
*/
#### Final Review exercise/*

In this exercise, you're going to manage a database schema that contains no constraints, allowing you to practice all the concepts that you learned in this lesson!

After exploring the schema, this is what you'll have to identify the following for each table, and add the appropriate constraints for them:

1.  Identify the primary key for each table
2.  Identify the unique constraints necessary for each table
3.  Identify the foreign key constraints necessary for each table
4.  In addition to the three types of constraints above, you'll have to implement some custom business rules:
- Usernames need to have a minimum of 5 characters
- A book's name cannot be empty
- A book's name must start with a capital letter
- A user's book preferences have to be distinct*/

#### Final Review Exercise Solution/*

-Remember to always use \dt and \d table_name to explore a new database before interacting with it! You'll gain many insights into the data types and constraints defined in that database.

Answer to Questions 1 and 2 below:
*/
-- Primary and unique keys
ALTER TABLE "users"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("username"),
  ADD UNIQUE ("email");


ALTER TABLE "books"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("isbn");


ALTER TABLE "user_book_preferences"
  ADD PRIMARY KEY ("user_id", "book_id");
/*
3.*/
  -- Foreign keys
  ALTER TABLE "user_book_preferences"
    ADD FOREIGN KEY ("user_id") REFERENCES "users",
    ADD FOREIGN KEY ("book_id") REFERENCES "books";/*

4.*/

-- Usernames need to have a minimum of 5 characters
ALTER TABLE "users" ADD CHECK (LENGTH("username") >= 5);


-- A book's name cannot be empty
ALTER TABLE "books" ADD CHECK(LENGTH(TRIM("name")) > 0);


-- A book's name must start with a capital letter
ALTER TABLE "books" ADD CHECK (
  SUBSTR("name", 1, 1) = UPPER(SUBSTR("name", 1, 1))
);

-- A user's book preferences have to be distinct
ALTER TABLE "user_book_preferences" ADD UNIQUE ("user_id", "preference");

### Constraints: Conclusion/*

This lesson was fundamental in allowing us to get a tighter grip on our data. In the next and final lesson on relational databases,
we'll see how to keep the database performing well even when storing and querying large amounts of data!*/

#### Glossary /*

Key Term	             Definition
Constraint	           A rule that can be added at the table or column level to restrict insertion and updates of data based on business rules.
Unique Constraint	      Ensures that a column or set of columns are unique across all the rows of the table.
Primary Key Constraint	 Like a unique constraint, it enforces unique values across a column or set of columns. In addition to that, it also enforces a NOT NULL, which is another database constraint that can be used by itself to ensure that a column's values cannot be null. Lastly, there can only be one of these for a given table.
Surrogate Key	            A primary key that is composed of a value not present in the business data, an artificial value created only for the purpose of uniquely identifying the rest of the data. It is not exposed to users of the system.
Natural key	              When a primary key is composed of a value that is present in the business data and exposed to users of the system.
Foreign Key Constraint	   Restricts the values in a column to only values that appear in another column. They're often used to relate IDs in relationships between tables, thereby preserving what we call "referential integrity". In many cases, the foreign key will refer to a primary key in another table, but that is not necessary. Any column can be referenced by a foreign key constraint.
Referential Integrity	      The property of columns referencing other entities to be consistent and valid, only referring to existing data.
ON DELETE CASCADE	        When the referenced data gets deleted, the referencing rows of data will be automatically deleted as well.
ON DELETE SET NULL	       When the referenced data gets deleted, the referring column will have its value set to NULL. Since NULL is a special value, it won't break the foreign key constraint because it will be clear that the row of data is now referencing absolutely nothing.
Check Constraint	       Allows one to implement custom business rules at the level of the database, such as "a product can't have a negative quantity".
