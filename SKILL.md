# Agent Skills & Execution Steps

The agent is equipped with the following skills to execute the 7 phases of the database design project. 

## Skill 1: Business Requirement Analysis
* [cite_start]**Task:** Analyze the provided business description to identify actors, entities, attributes, relationships, cardinalities, and business rules[cite: 47].
* **Output:** A structured markdown document detailing the analysis.

## Skill 2: Conceptual Database Design
* [cite_start]**Task:** Design an Entity-Relationship Diagram (ERD) based on Skill 1[cite: 48].
* [cite_start]**Output:** A text-based representation of the ERD (e.g., Mermaid.js syntax or formatted text) clearly showing entities, attributes, and participation constraints[cite: 48].

## Skill 3: Logical Database Design
* [cite_start]**Task:** Convert the ERD into a relational schema[cite: 49].
* [cite_start]**Output:** A document listing relations, primary keys, foreign keys, candidate keys, and key constraints[cite: 49].

## Skill 4: Database Design Validation
* [cite_start]**Task:** Evaluate the relational schema against the initial business rules to ensure no anomalies and correct application of constraints[cite: 50].
* **Output:** A validation report.

## Skill 5: Database Implementation (DDL)
* [cite_start]**Task:** Write SQL Data Definition Language (DDL) statements to create the tables[cite: 51].
* [cite_start]**Output:** A `.sql` file containing `CREATE TABLE` statements with primary keys, foreign keys, `CHECK` constraints, and default values[cite: 51].

## Skill 6: Sample Data Preparation
* [cite_start]**Task:** Write SQL `INSERT` statements to populate the database with realistic sample data, covering normal operations and edge cases[cite: 52].
* **Output:** A `.sql` file containing the insert scripts.

## Skill 7: Query Design
* [cite_start]**Task:** Design 5 meaningful SQL queries to answer business questions[cite: 53]. [cite_start]Each query must include the business question, target user, explanation of utility, and the SQL statement[cite: 54, 55, 56, 57, 58].
* **Output:** A `.sql` file containing the queries and their corresponding metadata as comments.