/*
Created: 23.03.2026
Modified: 07.04.2026
Project: BankSystem
Model: CSRS
Database: PostgreSQL 12
*/

-- Create tables section -------------------------------------------------

-- Table risk_request

CREATE TABLE "risk_request"
(
  "id" Serial NOT NULL,
  "lms_ext_id" Bigint NOT NULL,
  "created_at" Timestamp NOT NULL,
  "requested_amount" Money NOT NULL,
  "requested_term" Integer NOT NULL,
  "comment" Text,
  "status_id" Integer
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_requestStatus" ON "risk_request" ("status_id")
;

ALTER TABLE "risk_request" ADD CONSTRAINT "PK_risk_request" PRIMARY KEY ("id")
;

-- Table request_status

CREATE TABLE "request_status"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "request_status" ADD CONSTRAINT "PK_request_status" PRIMARY KEY ("id")
;

ALTER TABLE "request_status" ADD CONSTRAINT "request_status_name" UNIQUE ("name")
;

-- Table data_source

CREATE TABLE "data_source"
(
  "id" Serial NOT NULL,
  "name" Character varying(200) NOT NULL,
  "is_external" Boolean DEFAULT true NOT NULL,
  "is_active" Boolean DEFAULT true NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "data_source" ADD CONSTRAINT "PK_data_source" PRIMARY KEY ("id")
;

ALTER TABLE "data_source" ADD CONSTRAINT "data_source_name" UNIQUE ("name")
;

-- Table source_check

CREATE TABLE "source_check"
(
  "id" Serial NOT NULL,
  "check_date" Timestamp NOT NULL,
  "data_source_id" Integer NOT NULL,
  "risk_request_id" Integer NOT NULL,
  "check_result" Character varying(500),
  "status_id" Integer
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_dataSource" ON "source_check" ("data_source_id")
;

CREATE INDEX "IX_riskRequest" ON "source_check" ("risk_request_id")
;

CREATE INDEX "IX_checkStatus" ON "source_check" ("status_id")
;

ALTER TABLE "source_check" ADD CONSTRAINT "PK_source_check" PRIMARY KEY ("id")
;

-- Table check_status

CREATE TABLE "check_status"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "check_status" ADD CONSTRAINT "PK_check_status" PRIMARY KEY ("id")
;

ALTER TABLE "check_status" ADD CONSTRAINT "check_status_name" UNIQUE ("name")
;

-- Table scoring_model

CREATE TABLE "scoring_model"
(
  "id" Serial NOT NULL,
  "name" Character varying(150) NOT NULL,
  "version" Integer DEFAULT 1 NOT NULL,
  "start_use_date" Date NOT NULL,
  "end_use_date" Date,
  "is_active" Boolean DEFAULT true NOT NULL,
  "model_description" Text
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "scoring_model" ADD CONSTRAINT "PK_scoring_model" PRIMARY KEY ("id")
;

-- Table scoring_result

CREATE TABLE "scoring_result"
(
  "id" Serial NOT NULL,
  "risk_request_id" Integer NOT NULL,
  "score_model_id" Integer NOT NULL,
  "score_value" Numeric(10,2) NOT NULL,
  "score_date" Timestamp NOT NULL,
  "risk_level_id" Integer,
  "recommendation_id" Integer
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_specifiedRiskRequest" ON "scoring_result" ("risk_request_id")
;

CREATE INDEX "IX_scoreModel" ON "scoring_result" ("score_model_id")
;

CREATE INDEX "IX_riskLevel" ON "scoring_result" ("risk_level_id")
;

CREATE INDEX "IX_recommendation" ON "scoring_result" ("recommendation_id")
;

ALTER TABLE "scoring_result" ADD CONSTRAINT "PK_scoring_result" PRIMARY KEY ("id")
;

-- Table risk_level

CREATE TABLE "risk_level"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "risk_level" ADD CONSTRAINT "PK_risk_level" PRIMARY KEY ("id")
;

ALTER TABLE "risk_level" ADD CONSTRAINT "risk_level_name" UNIQUE ("name")
;

-- Table recommendation

CREATE TABLE "recommendation"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "recommendation" ADD CONSTRAINT "PK_recommendation" PRIMARY KEY ("id")
;

ALTER TABLE "recommendation" ADD CONSTRAINT "recommendation_name" UNIQUE ("name")
;

-- Table risk_factor

CREATE TABLE "risk_factor"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL,
  "value" Character varying(255),
  "scoring_result_id" Integer NOT NULL,
  "impact_level_id" Integer
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_scoringResult" ON "risk_factor" ("scoring_result_id")
;

CREATE INDEX "IX_impactLevel" ON "risk_factor" ("impact_level_id")
;

ALTER TABLE "risk_factor" ADD CONSTRAINT "PK_risk_factor" PRIMARY KEY ("id")
;

-- Table impact_level

CREATE TABLE "impact_level"
(
  "id" Serial NOT NULL,
  "name" Character varying(100) NOT NULL
)
WITH (
  autovacuum_enabled=true)
;

ALTER TABLE "impact_level" ADD CONSTRAINT "PK_impact_level" PRIMARY KEY ("id")
;

ALTER TABLE "impact_level" ADD CONSTRAINT "impact_level_name" UNIQUE ("name")
;

-- Table analytical_conclusion

CREATE TABLE "analytical_conclusion"
(
  "id" Serial NOT NULL,
  "date" Timestamp NOT NULL,
  "author_name" Character varying(200) NOT NULL,
  "text" Text NOT NULL,
  "recommendation_id" Integer,
  "risk_request_id" Integer
)
WITH (
  autovacuum_enabled=true)
;

CREATE INDEX "IX_conclusionRecommendation" ON "analytical_conclusion" ("recommendation_id")
;

CREATE INDEX "IX_conclusionRiskRequest" ON "analytical_conclusion" ("risk_request_id")
;

ALTER TABLE "analytical_conclusion" ADD CONSTRAINT "PK_analytical_conclusion" PRIMARY KEY ("id")
;

-- Create foreign keys (relationships) section -------------------------------------------------

ALTER TABLE "risk_request"
  ADD CONSTRAINT "specifiedRequestStatus"
    FOREIGN KEY ("status_id")
    REFERENCES "request_status" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "source_check"
  ADD CONSTRAINT "specifiedDataSource"
    FOREIGN KEY ("data_source_id")
    REFERENCES "data_source" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "source_check"
  ADD CONSTRAINT "specifiedRiskRequest"
    FOREIGN KEY ("risk_request_id")
    REFERENCES "risk_request" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "source_check"
  ADD CONSTRAINT "specifiedCheckStatus"
    FOREIGN KEY ("status_id")
    REFERENCES "check_status" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "scoring_result"
  ADD CONSTRAINT "specefiedRiskRequest"
    FOREIGN KEY ("risk_request_id")
    REFERENCES "risk_request" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "scoring_result"
  ADD CONSTRAINT "specefiedScoreModel"
    FOREIGN KEY ("score_model_id")
    REFERENCES "scoring_model" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "scoring_result"
  ADD CONSTRAINT "specefiedRiskLevel"
    FOREIGN KEY ("risk_level_id")
    REFERENCES "risk_level" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "scoring_result"
  ADD CONSTRAINT "specefiedRecommendation"
    FOREIGN KEY ("recommendation_id")
    REFERENCES "recommendation" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "risk_factor"
  ADD CONSTRAINT "specifiedScoringResult"
    FOREIGN KEY ("scoring_result_id")
    REFERENCES "scoring_result" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "risk_factor"
  ADD CONSTRAINT "specifiedImpactLevel"
    FOREIGN KEY ("impact_level_id")
    REFERENCES "impact_level" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "analytical_conclusion"
  ADD CONSTRAINT "specefiedConclusionRecommendation"
    FOREIGN KEY ("recommendation_id")
    REFERENCES "recommendation" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

ALTER TABLE "analytical_conclusion"
  ADD CONSTRAINT "speceifiedConclusionRiskRequest"
    FOREIGN KEY ("risk_request_id")
    REFERENCES "risk_request" ("id")
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
;

