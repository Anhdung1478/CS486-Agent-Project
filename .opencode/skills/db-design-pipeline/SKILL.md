---
name: db-design-pipeline
description: Analyze business requirements and sequentially produce conceptual ERD, logical database design, DDL, sample data, and queries for the Campus Space Management System.
compatibility: opencode
---

# Database Design Pipeline Skill

Use this skill to transform the provided business requirements for the Campus Space Management System into a complete, validated database design.

## Important Behavior

Before generating any output, the agent must:
1. Read the provided `business-requirement.md` file fully.
2. Ensure strict traceability. Each step must build exclusively on the artifacts generated in the prior steps.
3. If a requirement is ambiguous or incomplete, continue with explicit assumptions, but clearly document these in an "Unresolved Questions / Assumptions" section at the top of the output.
4. Do not skip any files or jump straight to SQL generation.
5. **Strict Output Formatting:** Do NOT wrap your file outputs in markdown code fences (e.g., ````sql`, ````mermaid`, or ````markdown`). Output the raw text or code directly. 

## Required Output Files

Create the following files strictly in this order inside the `outputs/` directory:
1. `01-business-req-analysis-G11.md`
2. `02-erd-design-G11.md`
3. `03-logical-design-G11.md`
4. `04-design-validation-G11.md`
5. `05-db-definition-G11.sql`
6. `06-sample-data-G11.sql`
7. `07-query-design-G11.sql`

---

# Step 1: Business Requirement Analysis

**Save to:** `outputs/01-business-req-analysis-G11.md`

**Task:** Analyze the provided business description to structure the database parameters.
**The document must include:**
* A clear breakdown of Actors, Entities, Attributes, Relationships, and Cardinalities.
* A definitive list of Business Rules extracted from the text.
* An explicit "Assumptions" section if any details are inferred.

---

# Step 2: Conceptual Database Design / ERD

**Save to:** `outputs/02-erd-design-G11.md`
**Dependency:** This ERD must be based entirely on the document from Step 1.

**Task:** Design an Entity-Relationship Diagram (ERD).
**The document must include:**
* Raw text-based representation of the ERD using Mermaid.js (`erDiagram`) syntax.
* Clear visual indicators of entities, attributes, and participation constraints (Crow's Foot notation).
* **Constraint:** Do NOT include any comments (e.g., `%%`) inside the Mermaid diagram code. Do NOT wrap the output in ````mermaid` fences.

---

# Step 3: Logical Database Design

**Save to:** `outputs/03-logical-design-G11.md`
**Dependency:** This schema must be directly converted from the ERD in Step 2.

**Task:** Convert the conceptual ERD into a normalized relational schema.
**The document must include:**
* A structured list of all relations (tables).
* Clearly identified Primary Keys (PK), Foreign Keys (FK), and Candidate Keys.
* Explicitly stated key constraints.

---

# Step 4: Database Design Validation

**Save to:** `outputs/04-design-validation-G11.md`
**Dependency:** Evaluate the schema from Step 3 against the rules identified in Step 1.

**Task:** Validate the logical design.
**The document must include:**
* A comprehensive validation report ensuring no data anomalies exist.
* Verification that all initial business rules and constraints are correctly applied in the logical schema.

---

# Step 5: Database Implementation (DDL)

**Save to:** `outputs/05-db-definition-G11.sql`
**Dependency:** Translate the validated schema from Step 4 into code.

**Task:** Write standard SQL Data Definition Language (DDL) statements.
**The document must include:**
* `CREATE TABLE` statements for all entities.
* Proper implementation of Primary Keys, Foreign Keys, `CHECK` constraints, and `DEFAULT` values based on the business rules.
* Clean, well-formatted SQL (Do NOT wrap in ````sql` fences).

---

# Step 6: Sample Data Preparation

**Save to:** `outputs/06-sample-data-G11.sql`
**Dependency:** Populate the tables created in Step 5.

**Task:** Write SQL Data Manipulation Language (DML) statements.
**The document must include:**
* `INSERT` statements to populate the database with realistic sample data.
* Data that covers both normal operations and important exceptional/edge cases (e.g., overlapping booking attempts, maintenance conflicts).
* Clean, well-formatted SQL (Do NOT wrap in ````sql` fences).

---

# Step 7: Query Design

**Save to:** `outputs/07-query-design-G11.sql`
**Dependency:** Formulate queries that run on the schema from Step 5 using data from Step 6.

**Task:** Design 5 meaningful SQL queries to answer critical business questions.
**The document must include:**
For each of the 5 queries, provide:
1. The business question being answered (as a SQL comment).
2. The target user(s) who would run this query (as a SQL comment).
3. A short explanation of why the query is useful (as a SQL comment).
4. The executable SQL `SELECT` statement.
* Clean, well-formatted SQL (Do NOT wrap in ````sql` fences).