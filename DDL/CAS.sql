/*
Created: 09.03.2026
Modified: 07.04.2026
Project: BankSystem
Model: CAS
Version: 4f5956e
Database: PostgreSQL 12
*/

-- Create tables section -------------------------------------------------

-- Table borrower

CREATE TABLE "borrower"
(
  "id" Serial NOT NULL,
  "type" Character varying(20) NOT NULL,
  "full_name" Character varying(300) NOT NULL,
  "phone" Character varying(30),
  "email" Character varying(100),
  "vip_flag" Boolean NOT NULL,
  "reg_date" Timestamp with time zone,
  "inn" Character varying(12)
)
WITH (
  autovacuum_enabled=true)
;
COMMENT ON COLUMN "borrower"."inn" IS '12 знаков для физлица и 10 знаков для юрлица'
;

ALTER TABLE "borrower" ADD CONSTRAINT "PK_borrower" PRIMARY KEY ("id")
;

-- Table individual_borrower

CREATE TABLE "individual_borrower"
(
  "passport" Character varying(20) NOT NULL,
  "snils" Character varying(11),
  "birth_date" Date NOT NULL,
  "residential_address" Character varying(500),
  "registration_address" Character varying(500),
  "workplace" Character varying(50),
  "monthly_income" Money,
  "borrower_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_isIndividual" ON "individual_borrower" ("borrower_id")
;

ALTER TABLE "individual_borrower" ADD CONSTRAINT "PK_individual_borrower" PRIMARY KEY ("borrower_id")
;

-- Table legal_entity_borrower

CREATE TABLE "legal_entity_borrower"
(
  "full_name" Character varying(300) NOT NULL,
  "short_name" Character varying(200),
  "kpp" Character varying(20),
  "ogrn" Character varying(20) NOT NULL,
  "legal_address" Character varying(500) NOT NULL,
  "postal_addresss" Character varying(500),
  "ceo_full_name" Character varying(200),
  "contact_person" Character varying(200),
  "company_phone" Character varying(30),
  "annual_revenue" Money,
  "borrower_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_isLegalEntitty" ON "legal_entity_borrower" ("borrower_id")
;

ALTER TABLE "legal_entity_borrower" ADD CONSTRAINT "PK_legal_entity_borrower" PRIMARY KEY ("borrower_id")
;

ALTER TABLE "legal_entity_borrower" ADD CONSTRAINT "legal_borrower_id" UNIQUE ("borrower_id")
;

-- Table employee

CREATE TABLE "employee"
(
  "id" Serial NOT NULL,
  "full_name" Character varying(300) NOT NULL,
  "work_phone" Character varying(30),
  "email" Character varying(100),
  "position_id" Integer,
  "department_id" Integer
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

ALTER TABLE "employee" ADD CONSTRAINT "employee_id" UNIQUE ("id")
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

ALTER TABLE "v_position" ADD CONSTRAINT "name" UNIQUE ("name")
;

ALTER TABLE "v_position" ADD CONSTRAINT "position_code" UNIQUE ("code")
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

ALTER TABLE "v_department" ADD CONSTRAINT "Код отделения" UNIQUE ("code")
;

-- Table credit_product

CREATE TABLE "credit_product"
(
  "id" Serial NOT NULL,
  "name" Character varying(200) NOT NULL,
  "min_amount" Money NOT NULL,
  "max_amount" Money NOT NULL
    CONSTRAINT "CheckMaxAmount" CHECK (check(max_amount >= min_amount)),
  "min_term" Integer NOT NULL
    CONSTRAINT "CheckMinTerm" CHECK (check(min_term > 0)),
  "max_term" Integer NOT NULL
    CONSTRAINT "CheckMaxTerm" CHECK (check(max_term >= min_term)),
  "base_rate" Numeric(5,2) NOT NULL
    CONSTRAINT "CheckBaseRate" CHECK (check(base_rate > 0)),
  "is_active" Boolean DEFAULT true NOT NULL,
  "description" Text,
  "product_type_id" Integer
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_credit_type" ON "credit_product" ("product_type_id")
;

ALTER TABLE "credit_product" ADD CONSTRAINT "PK_credit_product" PRIMARY KEY ("id")
;

-- Table credit_product_type

CREATE TABLE "credit_product_type"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL,
  "code" Character varying(20) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "credit_product_type" ADD CONSTRAINT "PK_credit_product_type" PRIMARY KEY ("id")
;

-- Table application

CREATE TABLE "application"
(
  "id" Integer NOT NULL,
  "reg_num" Character varying(50) NOT NULL,
  "reg_date" Timestamp NOT NULL,
  "requested_amount" Money NOT NULL,
  "requested_term" Integer NOT NULL
    CONSTRAINT "CheckRequestedTerm" CHECK (check(requested_term > 0)),
  "purpose" Character varying(500),
  "comment" Text,
  "borrower_id" Integer NOT NULL,
  "employee_id" Integer,
  "product_id" Integer,
  "status_id" Integer
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_borrow" ON "application" ("borrower_id")
;

CREATE INDEX "IX_employee_register" ON "application" ("employee_id")
;

CREATE INDEX "IX_credit_product" ON "application" ("product_id")
;

CREATE INDEX "IX_application_status" ON "application" ("status_id")
;

ALTER TABLE "application" ADD CONSTRAINT "PK_application" PRIMARY KEY ("id")
;

ALTER TABLE "application" ADD CONSTRAINT "Регистрационный номер" UNIQUE ("reg_num")
;

-- Table application_status

CREATE TABLE "application_status"
(
  "id" Serial NOT NULL,
  "name" Character varying(50) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "application_status" ADD CONSTRAINT "PK_application_status" PRIMARY KEY ("id")
;

ALTER TABLE "application_status" ADD CONSTRAINT "status_name" UNIQUE ("name")
;

-- Table application_document

CREATE TABLE "application_document"
(
  "id" Serial NOT NULL,
  "name" Character varying(255) NOT NULL,
  "file_path" Character varying(500),
  "upload_date" Timestamp,
  "comment" Character varying(500),
  "application_id" Integer,
  "document_type_id" Integer,
  "status_id" Integer
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_document_attach" ON "application_document" ("application_id")
;

CREATE INDEX "IX_document_type" ON "application_document" ("document_type_id")
;

CREATE INDEX "IX_verification_status" ON "application_document" ("status_id")
;

ALTER TABLE "application_document" ADD CONSTRAINT "PK_application_document" PRIMARY KEY ("id")
;

-- Table application_document_type

CREATE TABLE "application_document_type"
(
  "id" Serial NOT NULL,
  "name" Character varying(50) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "application_document_type" ADD CONSTRAINT "PK_application_document_type" PRIMARY KEY ("id")
;

ALTER TABLE "application_document_type" ADD CONSTRAINT "document_type_name" UNIQUE ("name")
;

-- Table document_verification_status

CREATE TABLE "document_verification_status"
(
  "id" Serial NOT NULL,
  "name" Character varying(50) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "document_verification_status" ADD CONSTRAINT "PK_document_verification_status" PRIMARY KEY ("id")
;

-- Create foreign keys (relationships) section -------------------------------------------------

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

ALTER TABLE "individual_borrower"
  ADD CONSTRAINT "is"
    FOREIGN KEY ("borrower_id")
    REFERENCES "borrower" ("id")
      ON DELETE CASCADE
      ON UPDATE RESTRICT
;

ALTER TABLE "legal_entity_borrower"
  ADD CONSTRAINT "is"
    FOREIGN KEY ("borrower_id")
    REFERENCES "borrower" ("id")
      ON DELETE CASCADE
      ON UPDATE RESTRICT
;

ALTER TABLE "credit_product"
  ADD CONSTRAINT "specifiedCreditType"
    FOREIGN KEY ("product_type_id")
    REFERENCES "credit_product_type" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "application"
  ADD CONSTRAINT "borrow"
    FOREIGN KEY ("borrower_id")
    REFERENCES "borrower" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "application"
  ADD CONSTRAINT "register"
    FOREIGN KEY ("employee_id")
    REFERENCES "employee" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "application"
  ADD CONSTRAINT "specifiedProduct"
    FOREIGN KEY ("product_id")
    REFERENCES "credit_product" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "application"
  ADD CONSTRAINT "specifiedStatus"
    FOREIGN KEY ("status_id")
    REFERENCES "application_status" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "application_document"
  ADD CONSTRAINT "attach"
    FOREIGN KEY ("application_id")
    REFERENCES "application" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "application_document"
  ADD CONSTRAINT "categorize"
    FOREIGN KEY ("document_type_id")
    REFERENCES "application_document_type" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "application_document"
  ADD CONSTRAINT "specifiedVerificationStatus"
    FOREIGN KEY ("status_id")
    REFERENCES "document_verification_status" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

