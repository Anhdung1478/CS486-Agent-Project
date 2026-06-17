```markdown
## Database Design Validation Report (Group 11)

**Assumptions:**
*   The validation assumes the logical schema provided in `03-logical-design-G11.md` is the target for validation.
*   The validation assumes the business rules extracted in `01-business-req-analysis-G11.md` are comprehensive and accurate.

---

### 1. Validation against Business Rules

This section validates the logical schema against each business rule identified in the initial analysis.

**Business Rule 1: Each user must have a university account. The system stores basic user information, including user ID, full name, email, phone number, role, department, and account status.**
*   **Validation:** The `Users` table includes `user_id` (PK), `full_name`, `email`, `phone_number`, `role`, `department`, and `account_status`. `user_id` is unique and serves as the primary identifier. `email` is also unique.
*   **Status:** **Validated.**

**Business Rule 2: A user may be a student, lecturer, teaching assistant, facility staff, department administrator, or facility manager.**
*   **Validation:** The `role` attribute in the `Users` table will likely be constrained by a `CHECK` constraint or an enumeration type in the physical schema to enforce these specific values.
*   **Status:** **Validated** (will be enforced at DDL level).

**Business Rule 3: For each space, the system stores a unique space code, space name, space type, building, floor, room number, capacity, current status, and usage policy.**
*   **Validation:** The `Spaces` table includes `space_id` (PK), `space_name`, `space_type`, `building`, `floor`, `room_number`, `capacity`, `current_status`, and `usage_policy`. `space_id` is unique. The combination of `building`, `floor`, and `room_number` is also unique.
*   **Status:** **Validated.**

**Business Rule 4: A space may be available, in use, under maintenance, temporarily closed, or retired.**
*   **Validation:** The `current_status` attribute in the `Spaces` table will be constrained by a `CHECK` constraint or an enumeration type in the physical schema to enforce these specific values.
*   **Status:** **Validated** (will be enforced at DDL level).

**Business Rule 5: Each space may have several facilities, such as a projector, whiteboard, microphone, computer, livestreaming equipment, or air conditioner. The system should store the list of facilities available in each space.**
*   **Validation:** The `Facilities` table stores `facility_id` (PK) and `facility_name`. The `SpaceFacilities` (junction) table links `Spaces` to `Facilities` via `space_id` and `facility_id`, allowing a many-to-many relationship.
*   **Status:** **Validated.**

**Business Rule 6: Users can submit booking requests by selecting a space, requested start time, requested end time, purpose of use, and expected number of participants.**
*   **Validation:** The `Bookings` table includes `booking_id` (PK), `user_id` (FK to `Users`), `space_id` (FK to `Spaces`), `requested_start_time`, `requested_end_time`, `purpose`, and `expected_participants`.
*   **Status:** **Validated.**

**Business Rule 7: A booking may be for a lecture, examination, seminar, workshop, meeting, student activity, or administrative event.**
*   **Validation:** The `purpose` attribute in the `Bookings` table will be constrained by a `CHECK` constraint or an enumeration type in the physical schema to enforce these specific values.
*   **Status:** **Validated** (will be enforced at DDL level).

**Business Rule 8: Each booking request has a status, such as pending, approved, rejected, cancelled, checked in, completed, or no-show.**
*   **Validation:** The `status` attribute in the `Bookings` table will be constrained by a `CHECK` constraint or an enumeration type in the physical schema to enforce these specific values.
*   **Status:** **Validated** (will be enforced at DDL level).

**Business Rule 9: The system must prevent conflicting bookings. The same space cannot have two approved bookings with overlapping time periods.**
*   **Validation:** This is a complex temporal constraint that typically requires application-level logic or advanced database features (e.g., exclusion constraints in PostgreSQL, or triggers). The logical schema provides the necessary `space_id`, `requested_start_time`, and `requested_end_time` attributes in the `Bookings` table, along with the `status` attribute, to implement this. A unique constraint on `(space_id, requested_start_time, requested_end_time)` combined with a `status = 'approved'` check would partially address it, but true overlap detection needs more. For a standard relational schema, this is primarily an application-level concern, but the schema provides the necessary data points.
*   **Status:** **Partially Validated** (Schema provides necessary attributes; full enforcement requires application logic or advanced DB features).

**Business Rule 10: A space that is under maintenance, closed, or retired cannot be booked.**
*   **Validation:** The `current_status` in the `Spaces` table and `status` in `MaintenanceRecords` (for `under maintenance`) provide the necessary information. This constraint will be enforced by application logic during booking submission and approval.
*   **Status:** **Partially Validated** (Schema provides necessary attributes; full enforcement requires application logic).

**Business Rule 11: A booking request may require approval from a facility staff member or manager.**
*   **Validation:** The `Bookings` table includes `approved_by_user_id` (FK to `Users`), `decision_time`, and `decision_note`. The `Users` table's `role` attribute allows identification of facility staff/managers.
*   **Status:** **Validated.**

**Business Rule 12: If the booking is rejected, the rejection reason should be stored.**
*   **Validation:** The `decision_note` attribute in the `Bookings` table can store the rejection reason.
*   **Status:** **Validated.**

**Business Rule 13: When the requester arrives, facility staff can check in the booking. The system records the actual start time, the person who checked in the booking, and the initial condition of the space.**
*   **Validation:** The `Bookings` table includes `actual_start_time`, `checked_in_by_user_id` (FK to `Users`), and `initial_condition_notes`.
*   **Status:** **Validated.**

**Business Rule 14: When the session ends, facility staff can complete the booking by recording the actual end time, the final condition of the space, and any usage notes.**
*   **Validation:** The `Bookings` table includes `actual_end_time`, `final_condition_notes`, and `usage_notes`.
*   **Status:** **Validated.**

**Business Rule 15: The system also supports basic maintenance management. A space may have maintenance records for problems such as broken projectors, air-conditioning failure, damaged furniture, cleaning issues, or network problems.**
*   **Validation:** The `MaintenanceRecords` table is designed for this, linking to `Spaces` via `space_id`. It includes `problem_description`.
*   **Status:** **Validated.**

**Business Rule 16: Each maintenance record stores the related space, reporter, assigned staff member, problem description, start time, completion time, status, and result note.**
*   **Validation:** The `MaintenanceRecords` table includes `maintenance_id` (PK), `space_id` (FK to `Spaces`), `reported_by_user_id` (FK to `Users`), `assigned_to_user_id` (FK to `Users`), `problem_description`, `start_time`, `completion_time`, `status`, and `result_note`.
*   **Status:** **Validated.**

**Business Rule 17: A space under maintenance cannot be booked.**
*   **Validation:** This is related to Business Rule 10. The `MaintenanceRecords` table's `status` attribute (e.g., 'active', 'pending', 'completed') and `start_time`/`completion_time` allow the application to determine if a space is currently under maintenance. This will be enforced by application logic.
*   **Status:** **Partially Validated** (Schema provides necessary attributes; full enforcement requires application logic).

**Business Rule 18: The system should keep historical records of bookings and maintenance activities.**
*   **Validation:** Both `Bookings` and `MaintenanceRecords` tables are designed to store records indefinitely, providing historical data. No explicit deletion or archiving strategy is implied, so the current design supports this.
*   **Status:** **Validated.**

**Business Rule 19: Staff should be able to view booking history, upcoming bookings, spaces under maintenance, and no-show bookings.**
*   **Validation:** The schema provides all necessary attributes (`Bookings.status`, `Bookings.requested_start_time`, `MaintenanceRecords.status`, `MaintenanceRecords.start_time`, `MaintenanceRecords.completion_time`) to construct queries for these views.
*   **Status:** **Validated.**

**Business Rule 20: The main goal of the system is to help the School manage shared campus spaces fairly, avoid overlapping bookings, prevent the use of unavailable spaces, and preserve usage history.**
*   **Validation:** The schema design directly supports these goals by providing structured data for bookings, space status, maintenance, and user roles, enabling the application to implement the necessary logic for fairness, conflict prevention, and historical tracking.
*   **Status:** **Validated.**

---

### 2. Data Anomalies Check

The logical design adheres to at least 3rd Normal Form (3NF), minimizing data anomalies:

*   **Insertion Anomalies:** No data can be inserted without a primary key, and non-key attributes are dependent on the full primary key. For example, a `Space` can be added without `Facilities` or `Bookings`, and a `User` can be added without `Bookings` or `MaintenanceRecords`.
*   **Deletion Anomalies:** Deleting a record in one table does not inadvertently delete unrelated information. For example, deleting a `Booking` does not delete the `User` or `Space` involved.
*   **Update Anomalies:** Information is stored in one place, preventing inconsistencies. For example, `Space` details are in the `Spaces` table only; updating a space's capacity only requires one change.

**Specific checks:**
*   **Normalization:**
    *   **1NF:** All tables have primary keys, and all attributes are atomic (e.g., `full_name` is a single attribute, not broken into first/last as per requirement, which is acceptable).
    *   **2NF:** All non-key attributes are fully functionally dependent on the primary key. This is ensured by the design (e.g., `space_name` depends on `space_id`, not just part of a composite key).
    *   **3NF:** No transitive dependencies exist. For example, `department` is an attribute of `Users`, not indirectly dependent on `user_id` through another non-key attribute. The `SpaceFacilities` table correctly handles the many-to-many relationship between `Spaces` and `Facilities`, preventing transitive dependencies.
*   **Referential Integrity:** Foreign keys are correctly identified, ensuring that references to primary keys in other tables are valid. This prevents orphaned records (e.g., a booking for a non-existent space).
*   **Uniqueness Constraints:** Primary keys ensure unique identification for each entity. Additional unique constraints (e.g., `email` for `Users`, `(building, floor, room_number)` for `Spaces`) prevent duplicate logical entries.
*   **Data Types and Domains:** While not explicitly defined in the logical schema, the attributes are chosen such that appropriate data types (e.g., `DATETIME` for times, `VARCHAR` for names, `INT` for capacity) can be assigned in the physical schema, and `CHECK` constraints will enforce domain integrity for status and role fields.

---

### 3. Conclusion

The logical database design effectively captures all entities, attributes, and relationships identified in the business requirements. It adheres to normalization principles (at least 3NF), minimizing data anomalies. Most business rules are directly supported by the schema structure, including primary/foreign keys, unique constraints, and attribute choices. Complex temporal constraints (e.g., preventing overlapping bookings, checking space availability based on maintenance) are identified as requiring additional application-level logic or advanced database features, but the schema provides all necessary data points for their implementation. The design is robust and provides a solid foundation for the Campus Space Management System.
```