/*
Created: 13.03.2026
Modified: 07.04.2026
Project: BankSystem
Model: LMS
Database: PostgreSQL 12
*/

-- Create tables section -------------------------------------------------

-- Table dossier

CREATE TABLE "dossier"
(
  "id" Serial NOT NULL,
  "cas_application_id" Bigint NOT NULL,
  "created_at" Timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "is_archive" Boolean DEFAULT false NOT NULL,
  "archived_at" Timestamp,
  "status_id" Integer NOT NULL,
  "comment" Text
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_dossier_status" ON "dossier" ("status_id")
;

ALTER TABLE "dossier" ADD CONSTRAINT "PK_dossier" PRIMARY KEY ("id")
;

-- Table dossier_status

CREATE TABLE "dossier_status"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "dossier_status" ADD CONSTRAINT "PK_dossier_status" PRIMARY KEY ("id")
;

ALTER TABLE "dossier_status" ADD CONSTRAINT "dossier_status_name" UNIQUE ("name")
;

-- Table risk_request

CREATE TABLE "risk_request"
(
  "id" Serial NOT NULL,
  "csrs_ext_id" Bigint NOT NULL,
  "created_at" Timestamp NOT NULL,
  "comment" Text,
  "status_id" Integer NOT NULL,
  "dossier_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_risk_req_status" ON "risk_request" ("status_id")
;

CREATE INDEX "IX_risk_req" ON "risk_request" ("dossier_id")
;

ALTER TABLE "risk_request" ADD CONSTRAINT "PK_risk_request" PRIMARY KEY ("id")
;

ALTER TABLE "risk_request" ADD CONSTRAINT "csrs_ext_id" UNIQUE ("csrs_ext_id")
;

-- Table risk_request_status

CREATE TABLE "risk_request_status"
(
  "id" Serial NOT NULL,
  "name" Character varying(50) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "risk_request_status" ADD CONSTRAINT "PK_risk_request_status" PRIMARY KEY ("id")
;

-- Table application_decision

CREATE TABLE "application_decision"
(
  "id" Serial NOT NULL,
  "decision_date" Timestamp NOT NULL,
  "approved_amount" Money,
  "approved_term" Integer,
  "approved_rate" Numeric(5,2),
  "dossier_id" Integer NOT NULL,
  "decision_type_id" Integer NOT NULL,
  "committee_id" Integer
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_make_decision" ON "application_decision" ("dossier_id")
;

CREATE INDEX "IX_decision_type" ON "application_decision" ("decision_type_id")
;

CREATE INDEX "IX_committee_decision" ON "application_decision" ("committee_id")
;

ALTER TABLE "application_decision" ADD CONSTRAINT "PK_application_decision" PRIMARY KEY ("id")
;

-- Table decision_type

CREATE TABLE "decision_type"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "decision_type" ADD CONSTRAINT "PK_decision_type" PRIMARY KEY ("id")
;

ALTER TABLE "decision_type" ADD CONSTRAINT "decision_type_name" UNIQUE ("name")
;

-- Table v_department

CREATE TABLE "v_department"
(
  "id" Serial NOT NULL,
  "name" Character varying(200) NOT NULL,
  "code" Character varying(20) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "v_department" ADD CONSTRAINT "PK_v_department" PRIMARY KEY ("id")
;

ALTER TABLE "v_department" ADD CONSTRAINT "department_code" UNIQUE ("code")
;

-- Table v_position

CREATE TABLE "v_position"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL,
  "code" Bigint NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "v_position" ADD CONSTRAINT "PK_v_position" PRIMARY KEY ("id")
;

ALTER TABLE "v_position" ADD CONSTRAINT "position_id" UNIQUE ("id")
;

ALTER TABLE "v_position" ADD CONSTRAINT "position_name" UNIQUE ("name")
;

ALTER TABLE "v_position" ADD CONSTRAINT "position_code" UNIQUE ("code")
;

-- Table employee

CREATE TABLE "employee"
(
  "id" Serial NOT NULL,
  "full_name" Character varying(300) NOT NULL,
  "work_phone" Character varying(30),
  "email" Character varying(100),
  "position_id" Integer,
  "department_id" Integer,
  "role" Character varying(50)
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_employee_position" ON "employee" ("position_id")
;

CREATE INDEX "IX_employee_department" ON "employee" ("department_id")
;

ALTER TABLE "employee" ADD CONSTRAINT "PK_employee" PRIMARY KEY ("id")
;

-- Table credit_committee

CREATE TABLE "credit_committee"
(
  "id" Serial NOT NULL,
  "meeting_date" Timestamp NOT NULL,
  "protocol_number" Character varying(50) NOT NULL,
  "comment" Text
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "credit_committee" ADD CONSTRAINT "PK_credit_committee" PRIMARY KEY ("id")
;

ALTER TABLE "credit_committee" ADD CONSTRAINT "protocol_number" UNIQUE ("protocol_number")
;

-- Table loan

CREATE TABLE "loan"
(
  "id" Serial NOT NULL,
  "contract_id" Bigint NOT NULL,
  "amount" Money NOT NULL,
  "rate" Numeric(5,2) NOT NULL,
  "term" Integer NOT NULL,
  "open_date" Date NOT NULL,
  "close_date" Date,
  "is_problematic" Boolean DEFAULT false NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_loanContract" ON "loan" ("contract_id")
;

ALTER TABLE "loan" ADD CONSTRAINT "PK_loan" PRIMARY KEY ("id")
;

-- Table loan_contract

CREATE TABLE "loan_contract"
(
  "id" Bigint NOT NULL,
  "dossier_id" Integer NOT NULL,
  "contract_number" Character varying(50) NOT NULL,
  "contract_date" Date NOT NULL,
  "file_path" Character varying(500)
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_specifiedDossier" ON "loan_contract" ("dossier_id")
;

ALTER TABLE "loan_contract" ADD CONSTRAINT "PK_loan_contract" PRIMARY KEY ("id")
;

ALTER TABLE "loan_contract" ADD CONSTRAINT "contract_number" UNIQUE ("contract_number")
;

-- Table payment_schedule

CREATE TABLE "payment_schedule"
(
  "id" Serial NOT NULL,
  "created_at" Timestamp NOT NULL,
  "schedule_version" Bigint DEFAULT 1 NOT NULL,
  "loan_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_specifiedLoan" ON "payment_schedule" ("loan_id")
;

ALTER TABLE "payment_schedule" ADD CONSTRAINT "PK_payment_schedule" PRIMARY KEY ("id")
;

-- Table payment_schedule_item

CREATE TABLE "payment_schedule_item"
(
  "id" Serial NOT NULL,
  "schedule_id" Integer NOT NULL,
  "payment_number" Integer NOT NULL,
  "due_date" Date NOT NULL,
  "payment_date" Date NOT NULL,
  "principal_due" Money NOT NULL,
  "interest_due" Money NOT NULL,
  "penalty_due" Money DEFAULT 0 NOT NULL,
  "payment" Money,
  "status_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_scheduleItemStatus" ON "payment_schedule_item" ("status_id")
;

ALTER TABLE "payment_schedule_item" ADD CONSTRAINT "PK_payment_schedule_item" PRIMARY KEY ("id","schedule_id")
;

-- Table schedule_item_status

CREATE TABLE "schedule_item_status"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "schedule_item_status" ADD CONSTRAINT "PK_schedule_item_status" PRIMARY KEY ("id")
;

ALTER TABLE "schedule_item_status" ADD CONSTRAINT "schedule_item_status_name" UNIQUE ("name")
;

-- Table dossier_event

CREATE TABLE "dossier_event"
(
  "id" Serial NOT NULL,
  "event_date" Timestamp NOT NULL,
  "decription" Text,
  "type_id" Integer,
  "dossier_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_dossierEventType" ON "dossier_event" ("type_id")
;

CREATE INDEX "IX_dossierEvent" ON "dossier_event" ("dossier_id")
;

ALTER TABLE "dossier_event" ADD CONSTRAINT "PK_dossier_event" PRIMARY KEY ("id")
;

-- Table dossier_event_type

CREATE TABLE "dossier_event_type"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "dossier_event_type" ADD CONSTRAINT "PK_dossier_event_type" PRIMARY KEY ("id")
;

ALTER TABLE "dossier_event_type" ADD CONSTRAINT "dossier_event_name" UNIQUE ("name")
;

-- Table loan_event

CREATE TABLE "loan_event"
(
  "id" Serial NOT NULL,
  "event_date" Timestamp NOT NULL,
  "decription" Text,
  "type_id" Integer,
  "loan_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_loanEventType" ON "loan_event" ("type_id")
;

CREATE INDEX "IX_loanEvent" ON "loan_event" ("loan_id")
;

ALTER TABLE "loan_event" ADD CONSTRAINT "PK_loan_event" PRIMARY KEY ("id")
;

-- Table loan_event_type

CREATE TABLE "loan_event_type"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "loan_event_type" ADD CONSTRAINT "PK_loan_event_type" PRIMARY KEY ("id")
;

ALTER TABLE "loan_event_type" ADD CONSTRAINT "loan_event_name" UNIQUE ("name")
;

-- Table committee_member

CREATE TABLE "committee_member"
(
  "employee_id" Integer NOT NULL,
  "committee_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "committee_member" ADD CONSTRAINT "PK_committee_member" PRIMARY KEY ("employee_id","committee_id")
;

-- Create foreign keys (relationships) section -------------------------------------------------

ALTER TABLE "dossier"
  ADD CONSTRAINT "specifiedDossierStatus"
    FOREIGN KEY ("status_id")
    REFERENCES "dossier_status" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "risk_request"
  ADD CONSTRAINT "specifiedRiskReqStatus"
    FOREIGN KEY ("status_id")
    REFERENCES "risk_request_status" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "risk_request"
  ADD CONSTRAINT "request"
    FOREIGN KEY ("dossier_id")
    REFERENCES "dossier" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "application_decision"
  ADD CONSTRAINT "make"
    FOREIGN KEY ("dossier_id")
    REFERENCES "dossier" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "application_decision"
  ADD CONSTRAINT "specifiedDecisionType"
    FOREIGN KEY ("decision_type_id")
    REFERENCES "decision_type" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "employee"
  ADD CONSTRAINT "specifiedPosition"
    FOREIGN KEY ("position_id")
    REFERENCES "v_position" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "employee"
  ADD CONSTRAINT "specifiedDepartment"
    FOREIGN KEY ("department_id")
    REFERENCES "v_department" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "application_decision"
  ADD CONSTRAINT "decide"
    FOREIGN KEY ("committee_id")
    REFERENCES "credit_committee" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "loan_contract"
  ADD CONSTRAINT "specifiedDossier"
    FOREIGN KEY ("dossier_id")
    REFERENCES "dossier" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "loan"
  ADD CONSTRAINT "specifiedLoanContract"
    FOREIGN KEY ("contract_id")
    REFERENCES "loan_contract" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "payment_schedule"
  ADD CONSTRAINT "specifiedLoan"
    FOREIGN KEY ("loan_id")
    REFERENCES "loan" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "payment_schedule_item"
  ADD CONSTRAINT "containsScheduleItem"
    FOREIGN KEY ("schedule_id")
    REFERENCES "payment_schedule" ("id")
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;

ALTER TABLE "payment_schedule_item"
  ADD CONSTRAINT "specifiedScheduleItemStatus"
    FOREIGN KEY ("status_id")
    REFERENCES "schedule_item_status" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "dossier_event"
  ADD CONSTRAINT "specifiedDossierEventType"
    FOREIGN KEY ("type_id")
    REFERENCES "dossier_event_type" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "dossier_event"
  ADD CONSTRAINT "happendDossierEvent"
    FOREIGN KEY ("dossier_id")
    REFERENCES "dossier" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "loan_event"
  ADD CONSTRAINT "specifiedLoanEventType"
    FOREIGN KEY ("type_id")
    REFERENCES "loan_event_type" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "loan_event"
  ADD CONSTRAINT "happendLoanEvent"
    FOREIGN KEY ("loan_id")
    REFERENCES "loan" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "committee_member"
  ADD CONSTRAINT "consistsCommittee"
    FOREIGN KEY ("employee_id")
    REFERENCES "employee" ("id")
      ON DELETE CASCADE
      ON UPDATE RESTRICT
;

ALTER TABLE "committee_member"
  ADD CONSTRAINT "containsEmployees"
    FOREIGN KEY ("committee_id")
    REFERENCES "credit_committee" ("id")
      ON DELETE CASCADE
      ON UPDATE RESTRICT
;

