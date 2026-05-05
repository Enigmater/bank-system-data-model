/*
Created: 24.03.2026
Modified: 05.05.2026
Project: BankSystem
Model: BAS
Database: PostgreSQL 12
*/

-- Create tables section -------------------------------------------------

-- Table loan_account

CREATE TABLE "loan_account"
(
  "id" Serial NOT NULL,
  "lms_ext_id" Integer NOT NULL,
  "account_number" Character varying(50) NOT NULL,
  "open_date" Date NOT NULL,
  "close_date" Date,
  "balance" Money NOT NULL,
  "status_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_accountStatus" ON "loan_account" ("status_id")
;

ALTER TABLE "loan_account" ADD CONSTRAINT "PK_loan_account" PRIMARY KEY ("id","lms_ext_id")
;

ALTER TABLE "loan_account" ADD CONSTRAINT "account_number" UNIQUE ("account_number")
;

-- Table account_status

CREATE TABLE "account_status"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "account_status" ADD CONSTRAINT "PK_account_status" PRIMARY KEY ("id")
;

ALTER TABLE "account_status" ADD CONSTRAINT "account_status_name" UNIQUE ("name")
;

-- Table disbursement

CREATE TABLE "disbursement"
(
  "id" Serial NOT NULL,
  "loan_account_id" Integer NOT NULL,
  "status_id" Integer NOT NULL,
  "disbursement_date" Timestamp NOT NULL,
  "amount" Money NOT NULL,
  "lms_ext_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_disbursementStatus" ON "disbursement" ("status_id")
;

ALTER TABLE "disbursement" ADD CONSTRAINT "PK_disbursement" PRIMARY KEY ("id","loan_account_id","lms_ext_id")
;

-- Table disbursement_status

CREATE TABLE "disbursement_status"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "disbursement_status" ADD CONSTRAINT "PK_disbursement_status" PRIMARY KEY ("id")
;

ALTER TABLE "disbursement_status" ADD CONSTRAINT "disbursement_status_name" UNIQUE ("name")
;

-- Table payment

CREATE TABLE "payment"
(
  "id" Serial NOT NULL,
  "date" Timestamp NOT NULL,
  "payment" Money NOT NULL,
  "account_id" Integer NOT NULL,
  "payment_channel_id" Integer NOT NULL,
  "status_id" Integer,
  "lms_ext_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_paymentChannel" ON "payment" ("payment_channel_id")
;

CREATE INDEX "IX_paymentStatus" ON "payment" ("status_id")
;

ALTER TABLE "payment" ADD CONSTRAINT "PK_payment" PRIMARY KEY ("id","account_id","lms_ext_id")
;

-- Table payment_status

CREATE TABLE "payment_status"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "payment_status" ADD CONSTRAINT "PK_payment_status" PRIMARY KEY ("id")
;

ALTER TABLE "payment_status" ADD CONSTRAINT "payment_status_name" UNIQUE ("name")
;

-- Table payment_channel

CREATE TABLE "payment_channel"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "payment_channel" ADD CONSTRAINT "PK_payment_channel" PRIMARY KEY ("id")
;

ALTER TABLE "payment_channel" ADD CONSTRAINT "payment_channel_name" UNIQUE ("name")
;

-- Table payment_allocation

CREATE TABLE "payment_allocation"
(
  "id" Serial NOT NULL,
  "amount" Money NOT NULL,
  "payment_id" Integer NOT NULL,
  "spread_type_id" Integer NOT NULL,
  "account_id" Integer NOT NULL,
  "lms_ext_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_spreadType" ON "payment_allocation" ("spread_type_id")
;

ALTER TABLE "payment_allocation" ADD CONSTRAINT "PK_payment_allocation" PRIMARY KEY ("id","payment_id","account_id","lms_ext_id")
;

-- Table allocation_type

CREATE TABLE "allocation_type"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "allocation_type" ADD CONSTRAINT "PK_allocation_type" PRIMARY KEY ("id")
;

ALTER TABLE "allocation_type" ADD CONSTRAINT "allocation_type_name" UNIQUE ("name")
;

-- Table overdue

CREATE TABLE "overdue"
(
  "id" Serial NOT NULL,
  "detection_date" Timestamp NOT NULL,
  "overdue_amount" Money NOT NULL,
  "days_overdue" Integer NOT NULL,
  "comment" Text,
  "status_id" Integer NOT NULL,
  "account_id" Integer NOT NULL,
  "lms_ext_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_overdueStatus" ON "overdue" ("status_id")
;

ALTER TABLE "overdue" ADD CONSTRAINT "PK_overdue" PRIMARY KEY ("id","account_id","lms_ext_id")
;

-- Table overdue_status

CREATE TABLE "overdue_status"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "overdue_status" ADD CONSTRAINT "PK_overdue_status" PRIMARY KEY ("id")
;

ALTER TABLE "overdue_status" ADD CONSTRAINT "overdue_status_name" UNIQUE ("name")
;

-- Table loan_snapshot

CREATE TABLE "loan_snapshot"
(
  "id" Serial NOT NULL,
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

ALTER TABLE "loan_snapshot" ADD CONSTRAINT "PK_loan_snapshot" PRIMARY KEY ("id")
;

-- Table obligation_closure

CREATE TABLE "obligation_closure"
(
  "id" Serial NOT NULL,
  "closure_date" Timestamp NOT NULL,
  "final_balance" Money NOT NULL,
  "confirmation_flag" Boolean DEFAULT false NOT NULL,
  "comment" Text,
  "account_id" Integer NOT NULL,
  "lms_ext_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "obligation_closure" ADD CONSTRAINT "PK_obligation_closure" PRIMARY KEY ("id","account_id","lms_ext_id")
;

-- Table payment_schedule_snapshot

CREATE TABLE "payment_schedule_snapshot"
(
  "id" Serial NOT NULL,
  "created_at" Timestamp NOT NULL,
  "schedule_version" Bigint DEFAULT 1 NOT NULL,
  "loan_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "payment_schedule_snapshot" ADD CONSTRAINT "PK_payment_schedule_snapshot" PRIMARY KEY ("id","loan_id")
;

-- Table payment_schedule_item_snapshot

CREATE TABLE "payment_schedule_item_snapshot"
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
  "status" Character varying(50) NOT NULL,
  "loan_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_scheduleItemStatus" ON "payment_schedule_item_snapshot" ("status")
;

ALTER TABLE "payment_schedule_item_snapshot" ADD CONSTRAINT "PK_payment_schedule_item_snapshot" PRIMARY KEY ("id","schedule_id","loan_id")
;

-- Table loan_bas_event

CREATE TABLE "loan_bas_event"
(
  "id" Serial NOT NULL,
  "event_date" Timestamp NOT NULL,
  "decription" Text,
  "type_id" Integer,
  "loan_account_id" Integer NOT NULL,
  "lms_ext_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_loanEventType" ON "loan_bas_event" ("type_id")
;

ALTER TABLE "loan_bas_event" ADD CONSTRAINT "PK_loan_bas_event" PRIMARY KEY ("id","loan_account_id","lms_ext_id")
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

-- Create foreign keys (relationships) section -------------------------------------------------

ALTER TABLE "loan_account"
  ADD CONSTRAINT "specefiedAccountStatus"
    FOREIGN KEY ("status_id")
    REFERENCES "account_status" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "disbursement"
  ADD CONSTRAINT "specefiedDisbursementStatus"
    FOREIGN KEY ("status_id")
    REFERENCES "disbursement_status" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "disbursement"
  ADD CONSTRAINT "specefiedAccount"
    FOREIGN KEY ("loan_account_id", "lms_ext_id")
    REFERENCES "loan_account" ("id", "lms_ext_id")
      ON DELETE CASCADE
      ON UPDATE RESTRICT
;

ALTER TABLE "payment"
  ADD CONSTRAINT "specifiedPaymentAccount"
    FOREIGN KEY ("account_id", "lms_ext_id")
    REFERENCES "loan_account" ("id", "lms_ext_id")
      ON DELETE CASCADE
      ON UPDATE RESTRICT
;

ALTER TABLE "payment"
  ADD CONSTRAINT "specifiedPaymentChannel"
    FOREIGN KEY ("payment_channel_id")
    REFERENCES "payment_channel" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "payment"
  ADD CONSTRAINT "specefiedPaymentStatus"
    FOREIGN KEY ("status_id")
    REFERENCES "payment_status" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "payment_allocation"
  ADD CONSTRAINT "spreadPayment"
    FOREIGN KEY ("payment_id", "account_id", "lms_ext_id")
    REFERENCES "payment" ("id", "account_id", "lms_ext_id")
      ON DELETE CASCADE
      ON UPDATE RESTRICT
;

ALTER TABLE "payment_allocation"
  ADD CONSTRAINT "specifiedSpreadType"
    FOREIGN KEY ("spread_type_id")
    REFERENCES "allocation_type" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "overdue"
  ADD CONSTRAINT "specefiedOverdueStatus"
    FOREIGN KEY ("status_id")
    REFERENCES "overdue_status" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "overdue"
  ADD CONSTRAINT "specefiedAccountOverdue"
    FOREIGN KEY ("account_id", "lms_ext_id")
    REFERENCES "loan_account" ("id", "lms_ext_id")
      ON DELETE CASCADE
      ON UPDATE RESTRICT
;

ALTER TABLE "obligation_closure"
  ADD CONSTRAINT "specifiedLoanClosure"
    FOREIGN KEY ("account_id", "lms_ext_id")
    REFERENCES "loan_account" ("id", "lms_ext_id")
      ON DELETE CASCADE
      ON UPDATE RESTRICT
;

ALTER TABLE "payment_schedule_snapshot"
  ADD CONSTRAINT "specifiedLoan"
    FOREIGN KEY ("loan_id")
    REFERENCES "loan_snapshot" ("id")
      ON DELETE CASCADE
      ON UPDATE RESTRICT
;

ALTER TABLE "payment_schedule_item_snapshot"
  ADD CONSTRAINT "containsScheduleItem"
    FOREIGN KEY ("schedule_id", "loan_id")
    REFERENCES "payment_schedule_snapshot" ("id", "loan_id")
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
;

ALTER TABLE "loan_account"
  ADD CONSTRAINT "specefiedExtLoan"
    FOREIGN KEY ("lms_ext_id")
    REFERENCES "loan_snapshot" ("id")
      ON DELETE CASCADE
      ON UPDATE RESTRICT
;

ALTER TABLE "loan_bas_event"
  ADD CONSTRAINT "specifiedLoanEventType"
    FOREIGN KEY ("type_id")
    REFERENCES "loan_event_type" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "loan_bas_event"
  ADD CONSTRAINT "specefiedLoanAccount"
    FOREIGN KEY ("loan_account_id", "lms_ext_id")
    REFERENCES "loan_account" ("id", "lms_ext_id")
      ON DELETE CASCADE
      ON UPDATE RESTRICT
;

