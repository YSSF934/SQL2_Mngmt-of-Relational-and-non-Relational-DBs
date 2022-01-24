
### Normalizing Data/*

- Denormalized data exhibits many issues:
* Inconsistent data types across a given column, making it difficult to manage and reason about
* Repeated columns, which disable us from scaling the number of items of related data
* Repeated values in a column, which make querying on those values more challenging
* The inability to uniquely identify rows of data to target them for manipulation
* Irrelevant dependencies, which cause repetitions and anomalies
* In this lesson, we'll learn how to normalize data through "normal forms" in order to avoid all the problems mentioned above.

- Going from denormalized to First Normal Form — 1NF:
* Make all values in a column consistently of the same data type
* Make sure each cell contains only a single value
* Make sure there are no repeating columns for the same data (e.g. category 1, 2, 3…)
* Enable the rows of data to be uniquely identified through a column or combination of columns

- To keep a single value in a cell, you might need to do two things:
* If multiple values in a cell are disjoint, e.g. a name and a code, split them into two columns—one for the name and one for the code
* If multiple values in a cell are the same type, e.g. a list of phone numbers, create multiple rows for that single row and put one of the values in each new row

-Removing repeating columns is done in a similar fashion to when a single cell contains multiple, comma-separated values: keep a single one of the repeating columns and duplicate
rows for each value in those columns.
- Candidate key: a set of one or more columns that can uniquely identify a row in a table
- Primary key: the key we choose from the candidate keys to uniquely represent a row in a table.

-Put each of the following two tables in First Normal Form. Each table constitutes a separate exercise.

First table
emp_number	emp_name	departments
1000      	Alice	         HR,Sales
1005	       Bob	      Sales
1420	       Cindy	    Engineering

Second table
post_id	          title	                          category1	  category2
10	       Everything wrong with the world	      Editorial	  Clickbait
11	        You won't believe this!	Clickbait

-I first noticed that departments clearly notes the potential for multiple values, and that Alice in fact had two departments listed.
I fixed this by adding another row and duplicating id and name, but splitting out the departments (and removing the “s” from the column name).
I also noted that I used emp_number and department to individually identify each row - the table’s primary key.

Solution
First table
emp_number	emp_name	department
1000      	Alice	         HR
1000        Alice       Sales
1005	       Bob	      Sales
1420	       Cindy	    Engineering

Second Table

-For the second table, I noticed that I had multiple “category” columns, as well as inconsistent datatypes in the post_id column. The first of these were pretty similar to the solve for the first table, although instead combining columns while adding rows, instead of splitting out values in a single cell.
The post_id then just needed to be a number.
Lastly, I added post_id and category as the primary key, as title probably won’t be unique in many cases.

Second table Solution
post_id	          title	                          category
10	       Everything wrong with the world	      Editorial
10         Everything wrong with the world	       Clickbait
11	       You won't believe this!	              Clickbait
1           Welcome to our blog

-Second Normal forms

Second Normal Form Recipe:

Bring table to First Normal Form
Remove all partial dependencies
-Partial dependency: a column that isn't part of the primary key, and that depends only on part of the primary key. For example, if the primary key (PK) is (student_no, course_id),
then a column called student_name would be a partial dependency on the PK because it only depends on the student_no.
-In the example, I noted item_name and variant_name as partial dependencies, relying on item_no and variant_code, respectively. As such, I split these two partial dependencies into their own tables, avoiding quite a bit of data duplication.
From there, the newly named item_id and variant_id (replacing item_no and variant_code) are the composite primary key for different item_variant quantities.
-Quiz
Why is the following table NOT in Second Normal Form?

student_id	course_id	course_name
10	CS-101	Intro to computer science
10	CS-103	Basics of C programming
12	CS-101	Introduction to computer science
15	ML-503	Advanced Machine Learning

Course_name only dpeends on course_id
For this exercise, you’re tasked with bringing the following data to Second Normal Form:

date	       employee_id	employee_name	  expense_amount	categories
2015-05-12	   5	        Bob	            25.48	            Food,Travel
2015-05-15	   42	        Travis	       forty dollars	      Taxi

To begin, I needed to get everything in First Normal Form, which in this case was noticing that multiple data types were used in expense_amount, and multiple values were present in some rows of the categories column.
By using just numeric values for expenses,and appropriately separating the categories by rows, we’ve met the first two goals of First Normal Form. The third goal is a little more complex, so let’s look at that next.
-Oddly enough, none of the original rows were able to be uniquely identified, even with a primary key of all the columns combined. In this case, I added an additional id column, and combined it with the category, to uniquely identify each row.
Now, we’ve achieved the first step of Second Normal Form - getting to First Normal Form.
-To get rid of the partial dependencies, I split out the category into another table that matches it up only to the expense id, since all other columns in a given row depend on the expense id. This gets us to Second Normal Form, although you might still think these tables look a little weird - let’s look into this.
-To make sure the category names aren’t inconsistent, one final step here might be to split these into a separate categories table, so that only the category id is included in the expense_categories table.
Surrogate Keys
-Sometimes, the data already existing in a table might not be enough to provide a sensible PK. In these cases, it would make sense to create an extra column that would be completely unrelated to the data, and use that to uniquely identify rows. Such a PK would be called a "surrogate" key.
-Just like a surrogate mother, it doesn't have any natural relationship with the rest of the columns in the table. Its only purpose is to allow targeting a specific row.
Recipe for Third Normal Form:
-Bring the table to Second Normal Form
-Eliminate transitive dependencies
Transitive dependency: when a column that isn't part of the primary key depends on the primary key, but through another non-key column. For example, a table of movie reviews would have a surrogate id column as its PK, and a movie_id column to refer to the movie which is being reviewed.
If the table also contains a movie_name column, then that movie_name is transitively dependent on the PK, because it depends on it through movie_id.
-To eliminate transitive dependencies, we'll use a strategy similar to that of eliminating partial dependencies: remove the concerned columns, and, if a table linking those columns to the one they depend on doesn't exist, create it. Keeping with the movie reviews example above, this would mean creating a table for movies, with an id and a movie_name,
and only keeping the movie_id column in the reviews table.
Third Normal Form Exercise
Bring the following data to Third Normal Form:

artist	agent_name	agent_phone1	agent_phone2
Alice	     Bob	        555-4200	     555-8080
Chad	     Denise	      555-6660
Emily	    Frank	        555-7777
To start, I added a row (or multiple rows, if there was more data) to make sure only one column contained phone numbers. I also decided artist and agent_phone would have to be the primary key, even though that’s clearly an awkward situation - for now. This gets the table into First Normal Form, so let’s look at Second Normal Form next.
-The pragmatic approach to resolving a lack of normal forms:
-Identify entities in the denormalized or partially normalized table
-Create new tables for each entity
-Go back to the original table and use it to relate the ids to each other
-In our case, this was more logically breaking out the data into artists, agents, and agent_phones tables.

-Sometimes, over-normalization can lead to absurd situations. One hint of this is if you find yourself having to do a ridiculous amount of JOINs in order to reconstruct a data-set, especially when the data you're joining rarely changes.
A great example of this is address data, where it's most often going to be OK to keep transitive dependencies for the benefit of having a customer's address all together in the same table: if one part of the address changes, it's likely that all of the address will change.
At the end of the day, each situation is different and you'll have to use your best judgment when determining where to normalize, in order to avoid repetitions and anomalies.
-Denormalized data contains repetitions that can cause anomalies
-Rules exist to normalize data
First Normal Form:
-Single-valued columns
-No repeating columns
-Consistent data across a column
-Uniquely identify a row
Second Normal Form: No partial dependencies
Third Normal Form: No transitive dependencies
Sometimes, it's OK to violate normal forms; use your best judgement
-Glossary
Key Term	Definition
First Normal Form (1NF)	Shaping data to eliminate inconsistencies, and allowing unique identification of each row
Second Normal Form (2NF)	Extends 1NF by removing partial dependencies
Third Normal Form (3NF)	Extends 2NF by removing transitive dependencies
One-One Relationship	When one entity "has one" of another entity, and that second entity "belongs to" only the first. For example, entity "user" and "home address" have a one-one relationship
One-Many Relationship	When one entity "has many" of another entity, and that second entity "belongs to" only the first. For example, entity "user" and "email address" have a one-many relationship, because a user can have many email addresses, but each email address belongs to only one user
Many-Many Relationship	When two entities are related in such a way where many links can exist on both sides. For example, entities "books" and "categories" have a many-many relationship, because a book can have multiple categories, and a category can belong to multiple books
Candidate Key	A set of one or more columns that can uniquely identify a row in a database table
Primary Key	The key from the set of candidate keys that we actually choose in order to uniquely identify a row in that table
Composite Key	A key that is composed of more than one column
Partial Dependency	When a non-key column depends on only part of the primary key
Transitive Dependency	When a non-key column depends on the primary key through another non-key column
