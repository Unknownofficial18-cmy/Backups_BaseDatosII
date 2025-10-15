--
-- PostgreSQL database dump
--

\restrict V3ru5N3WxMAaH48MCWGdFyOk5Weseha4sOiJXs7Qv4Ovwm64fMgv5rEciu7fSCl

-- Dumped from database version 14.19 (Debian 14.19-1.pgdg13+1)
-- Dumped by pg_dump version 14.19 (Debian 14.19-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: appointments_audit_action; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.appointments_audit_action AS ENUM (
    'UPDATE',
    'DELETE',
    'INSERT'
);


--
-- Name: diagnoses_audit_action; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.diagnoses_audit_action AS ENUM (
    'UPDATE',
    'DELETE',
    'INSERT'
);


--
-- Name: doctors_audit_action; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.doctors_audit_action AS ENUM (
    'UPDATE',
    'DELETE',
    'INSERT'
);


--
-- Name: patients_audit_action; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.patients_audit_action AS ENUM (
    'UPDATE',
    'DELETE',
    'INSERT'
);


--
-- Name: payments_audit_action; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.payments_audit_action AS ENUM (
    'UPDATE',
    'DELETE',
    'INSERT'
);


--
-- Name: recipedetails_audit_action; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.recipedetails_audit_action AS ENUM (
    'UPDATE',
    'DELETE',
    'INSERT'
);


--
-- Name: appointments_ad_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.appointments_ad_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_appointments_trigger', '1', true);

  INSERT INTO appointments_audit (id, "actionappointment", before_data, after_data)
  VALUES (
    OLD.id,
    'DELETE',
    jsonb_build_object(
      'id', OLD.id,
      'appointment_date', OLD.appointment_date,
      'doctor_id', OLD.doctor_id,
      'patient_id', OLD.patient_id,
 'reason', OLD.reason,
      'appointment_time', OLD.appointment_time
    ),
    NULL
  );

  PERFORM set_config('app.from_appointments_trigger', '', true);
  RETURN OLD;
END$$;


--
-- Name: appointments_ai_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.appointments_ai_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Activar variable de control para evitar recursion
  PERFORM set_config('app.from_appointments_trigger', '1', true);

  INSERT INTO appointments_audit (id, "actionappointment", before_data, after_data)
  VALUES (
    NEW.id,
    'INSERT',
    NULL,
    jsonb_build_object(
      'id', NEW.id,
      'appointment_date', NEW.appointment_date,
      'doctor_id', NEW.doctor_id,
      'patient_id', NEW.patient_id,
      'reason', NEW.reason,
'appointment_time',new.appointment_time
    )
  );

  PERFORM set_config('app.from_appointments_trigger', '', true);
  RETURN NEW;
END$$;


--
-- Name: appointments_au_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.appointments_au_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_appointments_trigger', '1', true);

  INSERT INTO appointments_audit (id, "actionappointment", before_data, after_data)
  VALUES (
    NEW.id,
    'UPDATE',
    jsonb_build_object(
      'id', OLD.id,
      'appointment_date', OLD.appointment_date,
      'doctor_id', OLD.doctor_id,
      'patient_id', OLD.patient_id,
'reason', OLD.reason,
      'appointment_time', OLD.appointment_time
    ),
    jsonb_build_object(
      'id', NEW.id,
      'appointment_date', NEW.appointment_date,
      'doctor_id', NEW.doctor_id,
      'patient_id', NEW.patient_id,
'reason', NEW.reason,
      'appointment_time', NEW.appointment_time

    )
  );

  PERFORM set_config('app.from_appointments_trigger', '', true);
  RETURN NEW;
END$$;


--
-- Name: appointments_audit_block_bd(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.appointments_audit_block_bd() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'appointments_audit es inmutable: DELETE prohibido.';
  RETURN OLD;
END$$;


--
-- Name: appointments_audit_block_bu(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.appointments_audit_block_bu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'appointments_audit es inmutable: UPDATE prohibido.';
  RETURN NEW;
END$$;


--
-- Name: appointments_audit_guard_bi(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.appointments_audit_guard_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  flag text;
BEGIN
  flag := current_setting('app.from_appointments_trigger', true);
  IF COALESCE(flag, '0') <> '1' THEN
    RAISE EXCEPTION 'INSERT en appointments_audit solo permitido desde triggers de appointments.';
  END IF;
  RETURN NEW;
END$$;


--
-- Name: buscar_paciente_like(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.buscar_paciente_like(texto character varying) RETURNS TABLE(id integer, name character varying, last_name character varying, telephone character varying, gender character varying, age integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT p.id, p.name, p.last_name, p.telephone,p.gender,p.age
    FROM patients p
    WHERE p.name LIKE '%' || texto || '%';
END;
$$;


--
-- Name: citas_por_paciente_igual(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.citas_por_paciente_igual(id_paciente integer) RETURNS TABLE(id_cita integer, appointment_date timestamp without time zone, reason character varying, paciente character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT a.id, a.appointment_date, a.reason, p.name
    FROM appointments a, patients p
    WHERE a.patient_id = p.id
      AND p.id = id_paciente;
END;
$$;


--
-- Name: citasdoctorjoin(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.citasdoctorjoin() RETURNS TABLE(id integer, appointment_date timestamp without time zone, reason character varying, doctor_name character varying, doctor_last_name character varying, specialty character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT a.id, a.appointment_date, a.reason,
           d.name, d.last_name, s.name_specialty
    FROM appointments a
     JOIN doctors d ON a.doctor_id = d.id
    JOIN specialties s ON d.specialty_id = s.id;
END;
$$;


--
-- Name: diagnoses_ai_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.diagnoses_ai_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_diagnoses_trigger','1', true);

  INSERT INTO diagnoses_audit (id, "actiondiagnosis", before_data, after_data)
  VALUES (
    NEW.id,
    'INSERT',
    NULL,
    jsonb_build_object(
      'id', NEW.id,
      'description', NEW.description,
      'patient_id', NEW.patient_id,
      'appointment_id', NEW.appointment_id
    )
  );

  PERFORM set_config('app.from_diagnoses_trigger','', true);
  RETURN NEW;
END$$;


--
-- Name: diagnoses_au_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.diagnoses_au_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_diagnoses_trigger','1', true);

  INSERT INTO diagnoses_audit (id, "actiondiagnosis", before_data, after_data)
  VALUES (
    NEW.id,
    'UPDATE',
    jsonb_build_object(
    'id', OLD.id,
      'description', OLD.description,
      'patient_id', OLD.patient_id,
      'appointment_id', OLD.appointment_id
    ),
    jsonb_build_object(
 'id', NEW.id,
      'description', NEW.description,
      'patient_id', NEW.patient_id,
      'appointment_id', NEW.appointment_id
    )
  );

  PERFORM set_config('app.from_diagnoses_trigger','', true);
  RETURN NEW;
END$$;


--
-- Name: diagnoses_audit_block_bd(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.diagnoses_audit_block_bd() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'diagnoses_audit es inmutable: DELETE prohibido.';
  RETURN OLD;
END$$;


--
-- Name: diagnoses_audit_block_bu(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.diagnoses_audit_block_bu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'diagnoses_audit es inmutable: UPDATE prohibido.';
  RETURN NEW;
END$$;


--
-- Name: diagnoses_audit_guard_bi(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.diagnoses_audit_guard_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  flag text;
BEGIN
  flag := current_setting('app.from_diagnoses_trigger', true);
  IF COALESCE(flag, '0') <> '1' THEN
    RAISE EXCEPTION 'INSERT en diagnoses_audit solo permitido desde triggers de diagnoses.';
  END IF;
  RETURN NEW;
END$$;


--
-- Name: diagnoses_bd_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.diagnoses_bd_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_diagnoses_trigger','1', true);

  INSERT INTO patients_audit (id, "actiondiagnosis", before_data, after_data)
  VALUES (
    OLD.id,
    'DELETE',
    jsonb_build_object(
    'id', OLD.id,
      'description', OLD.description,
      'patient_id', OLD.patient_id,
      'appointment_id', OLD.appointment_id
    ),
    NULL
  );

  PERFORM set_config('app.from_diagnoses_trigger','', true);
  RETURN OLD;
END$$;


--
-- Name: doctors_ai_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.doctors_ai_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_doctors_trigger','1', true);

  INSERT INTO doctors_audit (id, "actiondoctor", before_data, after_data)
  VALUES (
    NEW.id,
    'INSERT',
    NULL,
    jsonb_build_object(
      'id', NEW.id,
      'name', NEW.name,
      'last_name', NEW.last_name,
      'telephone', NEW.telephone,
'email',NEW.email,
'specialty_id', NEW.specialty_id
    )
  );

  PERFORM set_config('app.from_doctors_trigger','', true);
  RETURN NEW;
END$$;


--
-- Name: doctors_au_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.doctors_au_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_doctors_trigger','1', true);

  INSERT INTO doctors_audit (id, "actiondoctor", before_data, after_data)
  VALUES (
    NEW.id,
    'UPDATE',
    jsonb_build_object(
  'id', OLD.id,
      'name', OLD.name,
      'last_name', OLD.last_name,
      'telephone', OLD.telephone,
'email',OLD.email,
'specialty_id', OLD.specialty_id
    ),
    jsonb_build_object(
  'id', NEW.id,
      'name', NEW.name,
      'last_name', NEW.last_name,
      'telephone', NEW.telephone,
'email',NEW.email,
'specialty_id', NEW.specialty_id
    )
  );

  PERFORM set_config('app.from_doctors_trigger','', true);
  RETURN NEW;
END$$;


--
-- Name: doctors_audit_block_bd(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.doctors_audit_block_bd() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'doctors_audit es inmutable: DELETE prohibido.';
  RETURN OLD;
END$$;


--
-- Name: doctors_audit_block_bu(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.doctors_audit_block_bu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'doctors_audit es inmutable: UPDATE prohibido.';
  RETURN NEW;
END$$;


--
-- Name: doctors_audit_guard_bi(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.doctors_audit_guard_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  flag text;
BEGIN
  flag := current_setting('app.from_doctors_trigger', true);
  IF COALESCE(flag, '0') <> '1' THEN
    RAISE EXCEPTION 'INSERT en doctors_audit solo permitido desde triggers de doctors.';
  END IF;
  RETURN NEW;
END$$;


--
-- Name: doctors_bd_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.doctors_bd_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_doctors_trigger','1', true);

  INSERT INTO doctors_audit (id, "actiondoctor", before_data, after_data)
  VALUES (
    OLD.id,
    'DELETE',
    jsonb_build_object(
    'id', OLD.id,
      'name', OLD.name,
      'last_name', OLD.last_name,
      'telephone', OLD.telephone,
'email',OLD.email,
'specialty_id', OLD.specialty_id
    ),
    NULL
  );

  PERFORM set_config('app.from_doctors_trigger','', true);
  RETURN OLD;
END$$;


--
-- Name: pacientes_por_generowhere(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pacientes_por_generowhere(genero_param character varying) RETURNS TABLE(id integer, name character varying, last_name character varying, gender character varying, age integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT p.id, p.name, p.last_name, p.gender, p.age
    FROM patients p
    WHERE p.gender = genero_param;
END;
$$;


--
-- Name: pagos_fecha_between(date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pagos_fecha_between(fecha_i date, fecha_f date) RETURNS TABLE(id integer, payment_date date, amount numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT p.id, p.payment_date, p.amount
    FROM payments p
    WHERE p.payment_date BETWEEN fecha_i AND fecha_f;
END;
$$;


--
-- Name: patients_ai_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.patients_ai_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_patients_trigger','1', true);

  INSERT INTO patients_audit (id, "actionpatient", before_data, after_data)
  VALUES (
    NEW.id,
    'INSERT',
    NULL,
    jsonb_build_object(
      'id', NEW.id,
      'name', NEW.name,
      'last_name', NEW.last_name,
      'birth_date', NEW.birth_date,
      'gender', NEW.gender,
      'address', NEW.address,
      'phone', NEW.phone,
      'age', NEW.age
    )
  );

  PERFORM set_config('app.from_patients_trigger','', true);
  RETURN NEW;
END$$;


--
-- Name: patients_au_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.patients_au_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_patients_trigger','1', true);

  INSERT INTO patients_audit (id, "actionpatient", before_data, after_data)
  VALUES (
    NEW.id,
    'UPDATE',
    jsonb_build_object(
      'id', OLD.id,
      'name', OLD.name,
      'last_name', OLD.last_name,
      'birth_date', OLD.birth_date,
      'gender', OLD.gender,
      'address', OLD.address,
      'phone', OLD.phone,
      'age', OLD.age
    ),
    jsonb_build_object(
      'id', NEW.id,
      'name', NEW.name,
      'last_name', NEW.last_name,
      'birth_date', NEW.birth_date,
      'gender', NEW.gender,
      'address', NEW.address,
      'phone', NEW.phone,
      'age', NEW.age
    )
  );

  PERFORM set_config('app.from_patients_trigger','', true);
  RETURN NEW;
END$$;


--
-- Name: patients_audit_block_bd(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.patients_audit_block_bd() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'patients_audit es inmutable: DELETE prohibido.';
  RETURN OLD;
END$$;


--
-- Name: patients_audit_block_bu(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.patients_audit_block_bu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'patients_audit es inmutable: UPDATE prohibido.';
  RETURN NEW;
END$$;


--
-- Name: patients_audit_guard_bi(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.patients_audit_guard_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  flag text;
BEGIN
  flag := current_setting('app.from_patients_trigger', true);
  IF COALESCE(flag, '0') <> '1' THEN
    RAISE EXCEPTION 'INSERT en patients_audit solo permitido desde triggers de patients.';
  END IF;
  RETURN NEW;
END$$;


--
-- Name: patients_bd_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.patients_bd_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_patients_trigger','1', true);

  INSERT INTO patients_audit (id, "actionpatient", before_data, after_data)
  VALUES (
    OLD.id,
    'DELETE',
    jsonb_build_object(
      'id', OLD.id,
      'name', OLD.first_name,
      'last_name', OLD.last_name,
      'birth_date', OLD.birth_date,
      'gender', OLD.gender,
      'address', OLD.address,
      'phone', OLD.phone,
      'age', OLD.age
    ),
    NULL
  );

  PERFORM set_config('app.from_patients_trigger','', true);
  RETURN OLD;
END$$;


--
-- Name: payments_ai_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.payments_ai_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_payments_trigger','1', true);

  INSERT INTO payments_audit (id, "actionpayment", before_data, after_data)
  VALUES (
    NEW.id,
    'INSERT',
    NULL,
    jsonb_build_object(
      'id', NEW.id,
      'payment_date', NEW.payment_date,
      'amount', NEW.amount,
'appointment_id', new.appointment_id
    )
  );

  PERFORM set_config('app.from_payments_trigger','', true);
  RETURN NEW;
END$$;


--
-- Name: payments_au_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.payments_au_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_payments_trigger','1', true);

  INSERT INTO payments_audit (id, "actionpayment", before_data, after_data)
  VALUES (
    NEW.id,
    'UPDATE',
    jsonb_build_object(
      'id', OLD.id,
      'payment_date', OLD.payment_date,
      'amount', OLD.amount,
      'appointment_id', OLD.appointment_id
    ),
    jsonb_build_object(
      'id', NEW.id,
      'payment_date', NEW.payment_date,
      'amount', NEW.amount,
      'appointment_id', NEW.appointment_id
    )
  );

  PERFORM set_config('app.from_payments_trigger','', true);
  RETURN NEW;
END$$;


--
-- Name: payments_audit_block_bd(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.payments_audit_block_bd() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'payments_audit es inmutable: DELETE prohibido.';
  RETURN OLD;
END$$;


--
-- Name: payments_audit_block_bu(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.payments_audit_block_bu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'payments_audit es inmutable: UPDATE prohibido.';
  RETURN NEW;
END$$;


--
-- Name: payments_audit_guard_bi(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.payments_audit_guard_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  flag text;
BEGIN
  flag := current_setting('app.from_payments_trigger', true);
  IF COALESCE(flag, '0') <> '1' THEN
    RAISE EXCEPTION 'INSERT en payments_audit solo permitido desde triggers de payments.';
  END IF;
  RETURN NEW;
END$$;


--
-- Name: payments_bd_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.payments_bd_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_payments_trigger','1', true);

  INSERT INTO payments_audit (id, "actionpayment", before_data, after_data)
  VALUES (
    OLD.id,
    'DELETE',
    jsonb_build_object(
      'id', OLD.id,
      'payment_date', OLD.payment_date,
      'amount', OLD.amount,
      'appointment_id', OLD.appointment_id
    ),
    NULL
  );

  PERFORM set_config('app.from_payments_trigger','', true);
  RETURN OLD;
END$$;


--
-- Name: recipe_details_ai_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recipe_details_ai_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_recipe_details_trigger','1', true);

  INSERT INTO recipe_details_audit (id, "actionrecipe", before_data, after_data)
  VALUES (
    NEW.id,
    'INSERT',
    NULL,
    jsonb_build_object(
      'id', NEW.id,
      'amount', NEW.amount,
      'indications', NEW.indications,
      'prescription_id', NEW.prescription_id,
'medicine_id',NEW.medicine_id

    )
  );

  PERFORM set_config('app.from_recipe_details_trigger','', true);
  RETURN NEW;
END$$;


--
-- Name: recipe_details_au_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recipe_details_au_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_recipe_details_trigger','1', true);

  INSERT INTO recipe_details_audit (id, "actionrecipe", before_data, after_data)
  VALUES (
    NEW.id,
    'UPDATE',
    jsonb_build_object(
  'id', OLD.id,
      'amount', OLD.amount,
      'indications', OLD.indications,
      'prescription_id', OLD.prescription_id,
'medicine_id',OLD.medicine_id
    ),
    jsonb_build_object(
  'id', NEW.id,
      'amount', NEW.amount,
      'indications', NEW.indications,
      'prescription_id', NEW.prescription_id,
'medicine_id',NEW.medicine_id
    )
  );

  PERFORM set_config('app.from_recipe_details_trigger','', true);
  RETURN NEW;
END$$;


--
-- Name: recipe_details_audit_block_bd(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recipe_details_audit_block_bd() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'recipe_details_audit es inmutable: DELETE prohibido.';
  RETURN OLD;
END$$;


--
-- Name: recipe_details_audit_block_bu(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recipe_details_audit_block_bu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'recipe_details_audit es inmutable: UPDATE prohibido.';
  RETURN NEW;
END$$;


--
-- Name: recipe_details_audit_guard_bi(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recipe_details_audit_guard_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  flag text;
BEGIN
  flag := current_setting('app.from_recipe_details_trigger', true);
  IF COALESCE(flag, '0') <> '1' THEN
    RAISE EXCEPTION 'INSERT en recipe_details_audit solo permitido desde triggers de recipe_details.';
  END IF;
  RETURN NEW;
END$$;


--
-- Name: recipe_details_bd_audit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recipe_details_bd_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM set_config('app.from_recipe_details_trigger','1', true);

  INSERT INTO recipe_details_audit (id, "actionrecipe", before_data, after_data)
  VALUES (
    OLD.id,
    'DELETE',
    jsonb_build_object(
     'id', OLD.id,
      'amount', OLD.amount,
      'indications', OLD.indications,
      'prescription_id', OLD.prescription_id,
'medicine_id',OLD.medicine_id
    ),
    NULL
  );

  PERFORM set_config('app.from_recipe_details_trigger','', true);
  RETURN OLD;
END$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: appointments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appointments (
    id integer NOT NULL,
    appointment_date timestamp without time zone NOT NULL,
    patient_id integer NOT NULL,
    doctor_id integer NOT NULL,
    reason character varying(255),
    appointment_time time without time zone
);


--
-- Name: appointments_audit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appointments_audit (
    audit_id bigint NOT NULL,
    id bigint NOT NULL,
    actionappointment public.appointments_audit_action NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    changed_by text DEFAULT 'Admin'::text NOT NULL,
    before_data jsonb,
    after_data jsonb
);


--
-- Name: appointments_audit_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.appointments_audit ALTER COLUMN audit_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.appointments_audit_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: appointments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.appointments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appointments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.appointments_id_seq OWNED BY public.appointments.id;


--
-- Name: diagnoses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.diagnoses (
    id integer NOT NULL,
    description character varying(255) NOT NULL,
    patient_id integer NOT NULL,
    appointment_id integer NOT NULL
);


--
-- Name: diagnoses_audit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.diagnoses_audit (
    audit_id bigint NOT NULL,
    id bigint NOT NULL,
    actiondiagnosis public.diagnoses_audit_action NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    changed_by text DEFAULT 'Admin'::text NOT NULL,
    before_data jsonb,
    after_data jsonb
);


--
-- Name: diagnoses_audit_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.diagnoses_audit ALTER COLUMN audit_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.diagnoses_audit_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: diagnoses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.diagnoses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: diagnoses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.diagnoses_id_seq OWNED BY public.diagnoses.id;


--
-- Name: doctors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.doctors (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    telephone character varying(20),
    email character varying(150),
    specialty_id integer NOT NULL
);


--
-- Name: doctors_audit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.doctors_audit (
    audit_id bigint NOT NULL,
    id bigint NOT NULL,
    actiondoctor public.diagnoses_audit_action NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    changed_by text DEFAULT 'Admin'::text NOT NULL,
    before_data jsonb,
    after_data jsonb
);


--
-- Name: doctors_audit_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.doctors_audit ALTER COLUMN audit_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.doctors_audit_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: doctors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.doctors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: doctors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.doctors_id_seq OWNED BY public.doctors.id;


--
-- Name: medicines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medicines (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    presentation character varying(100),
    dose character varying(50)
);


--
-- Name: medicines_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.medicines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: medicines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.medicines_id_seq OWNED BY public.medicines.id;


--
-- Name: patients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patients (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    birth_date date NOT NULL,
    gender character varying(10) NOT NULL,
    address character varying(200),
    telephone character varying(20),
    age integer
);


--
-- Name: patients_audit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patients_audit (
    audit_id bigint NOT NULL,
    id bigint NOT NULL,
    actionpatient public.patients_audit_action NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    changed_by text DEFAULT 'Admin'::text NOT NULL,
    before_data jsonb,
    after_data jsonb
);


--
-- Name: patients_audit_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.patients_audit ALTER COLUMN audit_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.patients_audit_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: patients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.patients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: patients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.patients_id_seq OWNED BY public.patients.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    payment_date date NOT NULL,
    amount numeric(10,2) NOT NULL,
    appointment_id integer NOT NULL
);


--
-- Name: payments_audit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments_audit (
    audit_id bigint NOT NULL,
    id bigint NOT NULL,
    actionpayment public.payments_audit_action NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    changed_by text DEFAULT 'Admin'::text NOT NULL,
    before_data jsonb,
    after_data jsonb
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: prescriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prescriptions (
    id integer NOT NULL,
    prescription_date date NOT NULL,
    appointment_id integer NOT NULL
);


--
-- Name: prescriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.prescriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: prescriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.prescriptions_id_seq OWNED BY public.prescriptions.id;


--
-- Name: procedures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.procedures (
    id integer NOT NULL,
    description character varying(255) NOT NULL,
    appointment_id integer NOT NULL
);


--
-- Name: procedures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.procedures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: procedures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.procedures_id_seq OWNED BY public.procedures.id;


--
-- Name: recipe_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recipe_details (
    id integer NOT NULL,
    amount integer NOT NULL,
    indications character varying(255),
    prescription_id integer NOT NULL,
    medicine_id integer NOT NULL
);


--
-- Name: recipe_details_audit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recipe_details_audit (
    audit_id bigint NOT NULL,
    id bigint NOT NULL,
    actionrecipe public.recipedetails_audit_action NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    changed_by text DEFAULT 'Admin'::text NOT NULL,
    before_data jsonb,
    after_data jsonb
);


--
-- Name: recipe_details_audit_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.recipe_details_audit ALTER COLUMN audit_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.recipe_details_audit_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: recipe_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recipe_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recipe_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recipe_details_id_seq OWNED BY public.recipe_details.id;


--
-- Name: sales_audit_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.payments_audit ALTER COLUMN audit_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sales_audit_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: specialties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.specialties (
    id integer NOT NULL,
    name_specialty character varying(100) NOT NULL
);


--
-- Name: specialties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.specialties_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: specialties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.specialties_id_seq OWNED BY public.specialties.id;


--
-- Name: appointments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments ALTER COLUMN id SET DEFAULT nextval('public.appointments_id_seq'::regclass);


--
-- Name: diagnoses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnoses ALTER COLUMN id SET DEFAULT nextval('public.diagnoses_id_seq'::regclass);


--
-- Name: doctors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doctors ALTER COLUMN id SET DEFAULT nextval('public.doctors_id_seq'::regclass);


--
-- Name: medicines id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medicines ALTER COLUMN id SET DEFAULT nextval('public.medicines_id_seq'::regclass);


--
-- Name: patients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients ALTER COLUMN id SET DEFAULT nextval('public.patients_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: prescriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prescriptions ALTER COLUMN id SET DEFAULT nextval('public.prescriptions_id_seq'::regclass);


--
-- Name: procedures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procedures ALTER COLUMN id SET DEFAULT nextval('public.procedures_id_seq'::regclass);


--
-- Name: recipe_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_details ALTER COLUMN id SET DEFAULT nextval('public.recipe_details_id_seq'::regclass);


--
-- Name: specialties id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.specialties ALTER COLUMN id SET DEFAULT nextval('public.specialties_id_seq'::regclass);


--
-- Data for Name: appointments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.appointments (id, appointment_date, patient_id, doctor_id, reason, appointment_time) FROM stdin;
1	2025-05-12 00:00:00	51	4	Dolor	18:15:00
2	2023-11-02 00:00:00	69	51	Seguimiento de tratamiento	12:45:00
3	2024-03-08 00:00:00	36	100	Control	12:15:00
4	2023-05-26 00:00:00	123	34	Control	10:30:00
5	2023-07-15 00:00:00	151	65	Consulta general	07:30:00
6	2023-01-19 00:00:00	12	43	Dolor	12:15:00
7	2024-12-16 00:00:00	187	39	Seguimiento de tratamiento	15:30:00
8	2024-07-20 00:00:00	130	59	Valoración inicial	06:00:00
9	2024-02-04 00:00:00	193	58	Control	17:15:00
10	2021-01-04 00:00:00	26	25	Dolor	11:15:00
11	2021-12-24 00:00:00	5	9	Dolor	10:30:00
12	2023-09-16 00:00:00	9	58	Valoración inicial	07:45:00
13	2021-03-15 00:00:00	143	30	Control	16:45:00
14	2025-08-20 00:00:00	165	20	Dolor	07:30:00
15	2023-08-29 00:00:00	151	36	Seguimiento de tratamiento	06:45:00
16	2022-11-09 00:00:00	114	43	Reconsulta	08:30:00
17	2024-08-05 00:00:00	78	35	Consulta por referencia	09:45:00
18	2025-02-20 00:00:00	105	75	Consulta general	10:45:00
19	2021-04-09 00:00:00	113	69	Seguimiento de tratamiento	10:15:00
20	2024-01-09 00:00:00	29	91	Chequeo	11:30:00
21	2021-02-19 00:00:00	107	47	Chequeo	11:45:00
22	2025-01-16 00:00:00	51	47	Valoración inicial	06:45:00
23	2023-02-16 00:00:00	10	67	Valoración inicial	08:45:00
24	2024-01-31 00:00:00	33	59	Valoración inicial	15:30:00
25	2024-07-13 00:00:00	76	61	Reconsulta	09:15:00
26	2021-12-25 00:00:00	19	49	Valoración inicial	11:45:00
27	2024-11-15 00:00:00	142	8	Consulta general	16:45:00
28	2021-10-02 00:00:00	133	38	Consulta general	06:30:00
29	2024-05-11 00:00:00	66	39	Seguimiento de tratamiento	18:00:00
30	2023-11-09 00:00:00	57	7	Reconsulta	06:45:00
31	2023-09-30 00:00:00	86	26	Seguimiento de tratamiento	10:00:00
32	2023-05-17 00:00:00	76	55	Chequeo	15:15:00
33	2021-10-23 00:00:00	98	5	Consulta general	11:30:00
34	2021-07-12 00:00:00	100	38	Dolor	07:00:00
35	2025-01-17 00:00:00	48	71	Valoración inicial	08:15:00
36	2024-11-26 00:00:00	149	6	Chequeo	06:30:00
37	2024-08-11 00:00:00	100	76	Consulta general	11:00:00
38	2023-05-22 00:00:00	169	21	Control	08:30:00
39	2022-12-04 00:00:00	164	96	Reconsulta	15:00:00
40	2023-12-09 00:00:00	37	57	Consulta general	06:30:00
41	2024-11-20 00:00:00	3	75	Seguimiento de tratamiento	08:45:00
42	2022-03-29 00:00:00	47	11	Consulta por referencia	18:15:00
43	2022-04-30 00:00:00	109	97	Control	07:30:00
44	2021-04-02 00:00:00	39	88	Valoración inicial	12:00:00
45	2022-05-28 00:00:00	185	61	Consulta general	15:45:00
46	2022-06-04 00:00:00	34	41	Chequeo	08:45:00
47	2025-05-04 00:00:00	130	27	Consulta por referencia	08:00:00
48	2024-05-28 00:00:00	100	87	Seguimiento de tratamiento	17:15:00
49	2025-01-03 00:00:00	92	62	Reconsulta	17:30:00
50	2023-01-29 00:00:00	68	9	Urgencia	09:45:00
51	2021-02-06 00:00:00	47	63	Consulta por referencia	06:30:00
52	2024-01-30 00:00:00	191	60	Seguimiento de tratamiento	07:00:00
53	2023-03-24 00:00:00	169	50	Seguimiento de tratamiento	11:30:00
54	2022-01-22 00:00:00	23	96	Dolor	18:45:00
55	2024-05-22 00:00:00	74	96	Urgencia	09:00:00
56	2023-12-31 00:00:00	181	45	Seguimiento de tratamiento	08:15:00
57	2021-05-02 00:00:00	197	52	Urgencia	06:30:00
58	2025-02-07 00:00:00	158	81	Consulta general	11:15:00
59	2023-03-12 00:00:00	122	32	Chequeo	16:15:00
60	2021-07-20 00:00:00	107	38	Consulta general	17:15:00
61	2023-10-02 00:00:00	15	2	Consulta general	18:00:00
62	2024-01-11 00:00:00	66	50	Urgencia	09:00:00
63	2021-11-12 00:00:00	96	71	Reconsulta	15:00:00
64	2022-07-09 00:00:00	2	88	Reconsulta	09:45:00
65	2025-03-25 00:00:00	119	87	Consulta general	07:45:00
66	2022-07-12 00:00:00	95	51	Control	06:30:00
67	2023-02-03 00:00:00	78	83	Chequeo	17:45:00
68	2023-01-30 00:00:00	67	8	Reconsulta	15:30:00
69	2024-04-29 00:00:00	85	64	Control	12:15:00
70	2025-05-31 00:00:00	67	60	Valoración inicial	15:15:00
71	2021-04-10 00:00:00	114	90	Consulta general	14:45:00
72	2021-11-27 00:00:00	112	55	Seguimiento de tratamiento	11:00:00
73	2023-03-26 00:00:00	24	51	Control	09:00:00
74	2022-03-14 00:00:00	188	31	Chequeo	12:30:00
75	2023-10-19 00:00:00	44	35	Chequeo	06:15:00
76	2022-10-03 00:00:00	34	96	Reconsulta	09:30:00
77	2021-10-23 00:00:00	109	43	Control	06:45:00
78	2023-03-01 00:00:00	163	15	Chequeo	08:45:00
79	2021-06-12 00:00:00	9	62	Chequeo	08:15:00
80	2022-12-15 00:00:00	149	17	Valoración inicial	12:00:00
81	2021-10-02 00:00:00	40	27	Control	17:15:00
82	2022-08-21 00:00:00	71	19	Dolor	15:45:00
83	2022-04-27 00:00:00	170	5	Dolor	09:30:00
84	2023-05-08 00:00:00	84	13	Consulta por referencia	18:30:00
85	2023-05-14 00:00:00	90	31	Control	18:15:00
86	2024-03-17 00:00:00	129	18	Consulta por referencia	07:00:00
87	2024-02-26 00:00:00	99	37	Chequeo	14:45:00
88	2021-07-18 00:00:00	29	58	Consulta por referencia	17:15:00
89	2022-08-27 00:00:00	169	33	Consulta general	06:00:00
90	2022-06-06 00:00:00	66	43	Reconsulta	07:30:00
91	2024-02-10 00:00:00	2	4	Consulta general	14:15:00
92	2023-11-27 00:00:00	120	49	Consulta por referencia	17:45:00
93	2023-06-18 00:00:00	106	10	Control	10:45:00
94	2024-11-06 00:00:00	95	26	Dolor	07:15:00
95	2023-02-03 00:00:00	187	24	Reconsulta	18:30:00
96	2024-02-03 00:00:00	77	30	Control	14:00:00
97	2021-11-26 00:00:00	64	15	Consulta general	17:00:00
98	2024-09-01 00:00:00	102	29	Seguimiento de tratamiento	12:45:00
99	2023-08-29 00:00:00	74	93	Dolor	14:15:00
100	2022-01-19 00:00:00	57	32	Consulta por referencia	10:30:00
101	2024-12-29 00:00:00	165	49	Seguimiento de tratamiento	07:15:00
102	2023-11-29 00:00:00	187	35	Reconsulta	12:15:00
103	2023-06-21 00:00:00	69	47	Seguimiento de tratamiento	07:30:00
104	2022-07-12 00:00:00	85	65	Consulta por referencia	16:45:00
105	2025-01-28 00:00:00	69	11	Urgencia	10:30:00
106	2024-04-07 00:00:00	40	71	Consulta general	10:00:00
107	2022-05-09 00:00:00	23	88	Seguimiento de tratamiento	10:30:00
108	2021-09-13 00:00:00	134	98	Consulta por referencia	07:15:00
109	2025-06-03 00:00:00	152	74	Chequeo	12:15:00
110	2021-07-07 00:00:00	145	81	Chequeo	09:00:00
111	2024-01-31 00:00:00	53	33	Reconsulta	09:45:00
112	2022-01-09 00:00:00	198	15	Chequeo	14:00:00
113	2022-07-30 00:00:00	194	74	Seguimiento de tratamiento	17:00:00
114	2023-01-13 00:00:00	67	99	Consulta por referencia	15:45:00
115	2023-03-09 00:00:00	1	99	Seguimiento de tratamiento	12:15:00
116	2023-10-22 00:00:00	49	41	Reconsulta	16:00:00
117	2022-10-02 00:00:00	139	27	Dolor	18:30:00
118	2022-11-26 00:00:00	31	66	Consulta general	15:00:00
119	2022-11-19 00:00:00	66	54	Consulta general	07:00:00
120	2021-06-22 00:00:00	134	73	Reconsulta	16:00:00
121	2025-01-02 00:00:00	100	59	Consulta general	11:45:00
122	2023-11-10 00:00:00	111	71	Consulta por referencia	16:45:00
123	2023-08-30 00:00:00	193	86	Control	08:45:00
124	2021-08-21 00:00:00	57	19	Valoración inicial	18:45:00
125	2021-07-24 00:00:00	6	15	Chequeo	08:30:00
126	2025-04-02 00:00:00	198	36	Consulta por referencia	06:30:00
127	2023-01-05 00:00:00	5	82	Chequeo	06:45:00
128	2023-05-10 00:00:00	116	38	Consulta general	14:45:00
129	2023-04-12 00:00:00	82	88	Reconsulta	14:30:00
130	2022-09-18 00:00:00	55	94	Consulta general	09:30:00
131	2024-09-16 00:00:00	119	94	Dolor	17:15:00
132	2023-05-01 00:00:00	41	35	Consulta general	17:30:00
133	2025-02-06 00:00:00	118	90	Seguimiento de tratamiento	06:30:00
134	2023-07-02 00:00:00	107	5	Consulta por referencia	11:30:00
135	2022-01-26 00:00:00	11	41	Consulta por referencia	06:00:00
136	2022-09-22 00:00:00	137	5	Seguimiento de tratamiento	18:45:00
137	2023-10-22 00:00:00	23	35	Consulta general	18:15:00
138	2023-05-21 00:00:00	184	89	Consulta por referencia	18:30:00
139	2022-06-05 00:00:00	26	35	Dolor	10:30:00
140	2021-03-10 00:00:00	195	66	Reconsulta	10:15:00
141	2024-07-10 00:00:00	129	15	Valoración inicial	17:30:00
142	2025-01-02 00:00:00	75	29	Urgencia	15:45:00
143	2025-07-31 00:00:00	22	24	Reconsulta	08:00:00
144	2021-03-20 00:00:00	39	91	Dolor	15:00:00
145	2025-08-08 00:00:00	192	81	Control	09:30:00
146	2024-11-23 00:00:00	155	59	Consulta general	15:45:00
147	2021-10-02 00:00:00	133	21	Dolor	07:00:00
148	2022-12-24 00:00:00	20	86	Seguimiento de tratamiento	11:30:00
149	2021-01-25 00:00:00	152	26	Reconsulta	10:00:00
150	2021-04-15 00:00:00	54	49	Consulta general	09:00:00
151	2022-05-28 00:00:00	173	46	Seguimiento de tratamiento	17:30:00
152	2022-11-22 00:00:00	110	86	Urgencia	07:00:00
153	2025-09-07 00:00:00	186	34	Consulta general	07:15:00
154	2023-01-16 00:00:00	24	21	Seguimiento de tratamiento	10:45:00
155	2022-05-26 00:00:00	166	46	Urgencia	17:45:00
156	2024-05-20 00:00:00	175	8	Chequeo	07:00:00
157	2023-06-07 00:00:00	54	9	Reconsulta	06:30:00
158	2022-11-18 00:00:00	198	96	Seguimiento de tratamiento	15:45:00
159	2022-04-28 00:00:00	116	64	Valoración inicial	07:15:00
160	2022-03-08 00:00:00	196	98	Control	12:00:00
161	2021-07-25 00:00:00	165	18	Seguimiento de tratamiento	18:45:00
162	2021-03-03 00:00:00	110	56	Urgencia	06:45:00
163	2023-02-28 00:00:00	21	16	Dolor	11:45:00
164	2021-03-25 00:00:00	198	67	Control	18:00:00
165	2025-06-05 00:00:00	36	1	Reconsulta	12:45:00
166	2022-07-27 00:00:00	35	3	Consulta por referencia	07:30:00
167	2024-10-04 00:00:00	125	19	Chequeo	18:15:00
168	2023-11-06 00:00:00	126	56	Reconsulta	14:15:00
169	2023-09-07 00:00:00	187	59	Chequeo	10:00:00
170	2022-10-05 00:00:00	138	73	Reconsulta	16:15:00
171	2021-01-07 00:00:00	97	44	Reconsulta	08:00:00
172	2023-09-17 00:00:00	112	52	Reconsulta	07:00:00
173	2022-04-10 00:00:00	137	52	Chequeo	09:45:00
174	2023-10-30 00:00:00	99	73	Seguimiento de tratamiento	09:15:00
175	2021-04-11 00:00:00	133	45	Seguimiento de tratamiento	07:30:00
176	2022-02-28 00:00:00	148	45	Chequeo	12:15:00
177	2025-04-12 00:00:00	99	60	Control	06:15:00
178	2022-05-02 00:00:00	140	12	Valoración inicial	06:00:00
179	2025-03-03 00:00:00	48	1	Urgencia	11:15:00
180	2021-10-16 00:00:00	57	89	Valoración inicial	11:00:00
181	2025-07-27 00:00:00	139	31	Dolor	18:30:00
182	2021-02-16 00:00:00	141	34	Chequeo	08:15:00
183	2021-09-25 00:00:00	109	35	Reconsulta	18:30:00
184	2024-04-14 00:00:00	71	88	Dolor	18:30:00
185	2025-06-27 00:00:00	86	86	Consulta general	15:45:00
186	2021-10-13 00:00:00	59	17	Reconsulta	15:30:00
187	2021-12-18 00:00:00	179	14	Seguimiento de tratamiento	18:15:00
188	2022-11-13 00:00:00	53	76	Control	07:30:00
189	2023-11-21 00:00:00	194	76	Reconsulta	07:45:00
190	2023-10-23 00:00:00	63	63	Control	07:00:00
191	2024-02-11 00:00:00	191	73	Control	12:15:00
192	2023-09-24 00:00:00	110	9	Valoración inicial	15:30:00
193	2022-05-11 00:00:00	30	20	Consulta por referencia	11:30:00
194	2024-08-07 00:00:00	23	94	Reconsulta	15:00:00
195	2022-05-28 00:00:00	150	46	Consulta por referencia	15:30:00
196	2023-03-03 00:00:00	119	80	Consulta general	08:45:00
197	2022-02-13 00:00:00	167	73	Reconsulta	12:15:00
198	2022-02-03 00:00:00	3	36	Seguimiento de tratamiento	18:30:00
199	2024-09-07 00:00:00	85	90	Control	08:30:00
200	2025-06-16 00:00:00	45	23	Consulta general	18:15:00
201	2021-10-26 00:00:00	84	27	Urgencia	18:45:00
202	2023-04-02 00:00:00	149	31	Dolor	17:15:00
203	2021-06-19 00:00:00	102	86	Control	18:30:00
204	2022-02-13 00:00:00	195	58	Chequeo	08:15:00
205	2023-07-01 00:00:00	112	89	Seguimiento de tratamiento	12:30:00
206	2022-06-30 00:00:00	14	42	Consulta por referencia	17:15:00
207	2024-01-06 00:00:00	68	27	Consulta general	07:30:00
208	2021-05-22 00:00:00	163	72	Urgencia	16:30:00
209	2024-04-16 00:00:00	120	73	Control	15:30:00
210	2024-09-01 00:00:00	139	14	Consulta general	17:45:00
211	2022-03-21 00:00:00	180	72	Valoración inicial	17:00:00
212	2024-02-13 00:00:00	139	91	Consulta por referencia	12:00:00
213	2023-06-03 00:00:00	160	99	Dolor	08:00:00
214	2025-02-08 00:00:00	71	90	Reconsulta	11:15:00
215	2023-07-22 00:00:00	176	7	Valoración inicial	16:30:00
216	2025-01-06 00:00:00	119	81	Consulta por referencia	16:45:00
217	2023-02-09 00:00:00	147	39	Urgencia	06:15:00
218	2022-05-25 00:00:00	16	76	Consulta por referencia	08:45:00
219	2022-10-26 00:00:00	56	3	Seguimiento de tratamiento	07:00:00
220	2025-07-10 00:00:00	184	95	Urgencia	16:00:00
221	2023-09-03 00:00:00	154	51	Consulta general	14:15:00
222	2024-12-18 00:00:00	133	12	Dolor	10:30:00
223	2022-11-19 00:00:00	35	64	Control	16:15:00
224	2023-07-16 00:00:00	74	15	Consulta general	09:30:00
225	2021-07-31 00:00:00	57	36	Control	12:00:00
226	2024-05-09 00:00:00	183	52	Consulta general	15:00:00
227	2022-01-25 00:00:00	132	47	Seguimiento de tratamiento	11:45:00
228	2023-10-01 00:00:00	24	93	Chequeo	16:00:00
229	2024-09-02 00:00:00	12	19	Consulta por referencia	08:30:00
230	2021-05-31 00:00:00	102	20	Chequeo	12:00:00
231	2024-02-21 00:00:00	11	12	Control	07:30:00
232	2025-01-06 00:00:00	142	38	Control	06:00:00
233	2024-07-06 00:00:00	102	81	Seguimiento de tratamiento	10:30:00
234	2023-06-17 00:00:00	39	67	Urgencia	14:00:00
235	2024-08-24 00:00:00	128	64	Valoración inicial	07:30:00
236	2024-12-23 00:00:00	186	79	Urgencia	06:15:00
237	2025-09-13 00:00:00	32	30	Dolor	08:45:00
238	2025-03-28 00:00:00	121	27	Chequeo	18:00:00
239	2022-11-26 00:00:00	30	76	Reconsulta	10:15:00
240	2023-05-22 00:00:00	15	8	Consulta por referencia	06:30:00
241	2022-12-01 00:00:00	158	14	Urgencia	11:00:00
242	2022-06-02 00:00:00	36	44	Control	12:30:00
243	2023-06-18 00:00:00	30	93	Control	12:00:00
244	2023-04-27 00:00:00	188	37	Consulta por referencia	14:00:00
245	2021-08-02 00:00:00	38	40	Consulta por referencia	11:15:00
246	2021-05-11 00:00:00	121	22	Consulta general	07:00:00
247	2022-12-09 00:00:00	58	62	Reconsulta	14:00:00
248	2023-04-04 00:00:00	92	99	Reconsulta	11:45:00
249	2024-12-23 00:00:00	77	90	Seguimiento de tratamiento	11:30:00
250	2021-04-08 00:00:00	113	92	Consulta general	08:45:00
251	2023-03-07 00:00:00	11	74	Dolor	14:15:00
252	2025-02-20 00:00:00	31	71	Dolor	12:30:00
253	2023-05-27 00:00:00	77	23	Chequeo	07:30:00
254	2021-06-28 00:00:00	194	45	Valoración inicial	14:15:00
255	2023-03-06 00:00:00	78	22	Consulta por referencia	14:15:00
256	2025-07-23 00:00:00	79	28	Seguimiento de tratamiento	08:30:00
257	2021-07-09 00:00:00	79	32	Reconsulta	15:00:00
258	2024-06-08 00:00:00	98	38	Consulta general	08:15:00
259	2023-02-25 00:00:00	188	94	Valoración inicial	18:00:00
260	2022-09-04 00:00:00	16	91	Urgencia	12:30:00
261	2022-11-27 00:00:00	60	66	Urgencia	08:45:00
262	2024-09-11 00:00:00	175	94	Urgencia	18:15:00
263	2021-06-25 00:00:00	58	49	Chequeo	10:45:00
264	2023-07-19 00:00:00	88	60	Consulta general	11:45:00
265	2022-02-04 00:00:00	1	27	Dolor	15:30:00
266	2025-09-25 00:00:00	100	17	Valoración inicial	16:30:00
267	2021-05-30 00:00:00	138	4	Consulta por referencia	10:30:00
268	2021-06-07 00:00:00	139	7	Urgencia	07:45:00
269	2025-06-27 00:00:00	175	92	Chequeo	06:30:00
270	2022-08-09 00:00:00	122	91	Control	07:15:00
271	2023-11-27 00:00:00	55	26	Dolor	06:30:00
272	2021-08-19 00:00:00	105	52	Consulta general	18:45:00
273	2023-10-31 00:00:00	32	77	Consulta general	12:45:00
274	2025-08-13 00:00:00	191	95	Valoración inicial	10:30:00
275	2021-12-05 00:00:00	136	26	Chequeo	14:30:00
276	2023-02-16 00:00:00	165	44	Control	08:45:00
277	2021-07-19 00:00:00	132	37	Valoración inicial	15:30:00
278	2021-04-25 00:00:00	179	77	Chequeo	16:15:00
279	2025-09-03 00:00:00	43	68	Reconsulta	17:00:00
280	2024-07-28 00:00:00	148	31	Control	17:30:00
281	2023-01-20 00:00:00	69	50	Consulta por referencia	10:15:00
282	2022-07-29 00:00:00	102	59	Consulta general	12:45:00
283	2023-11-18 00:00:00	130	44	Valoración inicial	09:45:00
284	2023-08-22 00:00:00	118	3	Chequeo	17:00:00
285	2023-06-26 00:00:00	1	93	Seguimiento de tratamiento	10:15:00
286	2024-09-26 00:00:00	3	89	Dolor	10:00:00
287	2021-06-17 00:00:00	101	32	Reconsulta	16:30:00
288	2021-05-22 00:00:00	94	77	Consulta por referencia	08:15:00
289	2024-05-07 00:00:00	14	15	Seguimiento de tratamiento	12:00:00
290	2021-02-20 00:00:00	121	13	Dolor	12:00:00
291	2024-11-22 00:00:00	122	88	Consulta general	07:45:00
292	2024-12-06 00:00:00	193	29	Seguimiento de tratamiento	10:30:00
293	2021-07-21 00:00:00	192	86	Seguimiento de tratamiento	16:45:00
294	2024-11-06 00:00:00	148	63	Control	06:45:00
295	2022-12-17 00:00:00	63	37	Seguimiento de tratamiento	16:00:00
296	2022-12-12 00:00:00	193	37	Chequeo	12:15:00
297	2021-11-18 00:00:00	53	97	Dolor	17:45:00
298	2024-05-21 00:00:00	38	36	Reconsulta	07:45:00
299	2024-02-02 00:00:00	70	47	Consulta por referencia	08:00:00
300	2023-03-01 00:00:00	138	31	Chequeo	10:45:00
301	2021-05-27 00:00:00	23	16	Valoración inicial	09:15:00
302	2021-11-30 00:00:00	76	34	Seguimiento de tratamiento	17:00:00
303	2025-03-07 00:00:00	169	86	Control	11:15:00
304	2023-06-30 00:00:00	135	56	Control	08:15:00
305	2023-10-30 00:00:00	134	50	Consulta general	11:00:00
306	2022-09-06 00:00:00	1	53	Consulta por referencia	08:00:00
307	2021-05-22 00:00:00	79	10	Urgencia	08:00:00
308	2021-10-18 00:00:00	200	94	Dolor	12:45:00
309	2023-08-20 00:00:00	151	75	Consulta general	11:45:00
310	2022-11-28 00:00:00	110	14	Dolor	09:00:00
311	2025-02-15 00:00:00	94	69	Urgencia	11:00:00
312	2023-04-13 00:00:00	11	7	Reconsulta	12:30:00
313	2021-04-05 00:00:00	178	2	Consulta general	17:00:00
314	2024-09-22 00:00:00	41	63	Consulta general	11:00:00
315	2024-12-06 00:00:00	93	25	Seguimiento de tratamiento	09:45:00
316	2024-10-17 00:00:00	181	60	Consulta por referencia	15:00:00
317	2025-03-07 00:00:00	192	15	Consulta general	12:45:00
318	2024-07-26 00:00:00	71	68	Seguimiento de tratamiento	07:15:00
319	2022-05-29 00:00:00	26	24	Dolor	06:15:00
320	2022-11-27 00:00:00	123	90	Consulta general	08:00:00
321	2022-02-03 00:00:00	156	75	Consulta por referencia	14:00:00
322	2021-10-14 00:00:00	40	86	Consulta por referencia	07:30:00
323	2022-10-20 00:00:00	163	69	Dolor	14:15:00
324	2023-02-16 00:00:00	11	69	Dolor	11:45:00
325	2023-11-07 00:00:00	113	14	Urgencia	11:15:00
326	2021-11-01 00:00:00	24	69	Dolor	14:45:00
327	2022-07-13 00:00:00	47	38	Reconsulta	15:45:00
328	2024-07-14 00:00:00	68	59	Consulta por referencia	09:00:00
329	2025-05-17 00:00:00	51	69	Consulta por referencia	07:45:00
330	2023-07-29 00:00:00	167	92	Consulta general	17:00:00
331	2023-05-10 00:00:00	194	3	Dolor	12:15:00
332	2022-02-26 00:00:00	70	9	Urgencia	18:15:00
333	2022-09-27 00:00:00	19	36	Consulta general	06:30:00
334	2022-01-01 00:00:00	198	90	Chequeo	09:00:00
335	2022-02-14 00:00:00	196	49	Consulta general	18:15:00
336	2024-02-25 00:00:00	185	97	Seguimiento de tratamiento	18:15:00
337	2025-09-26 00:00:00	143	47	Consulta general	14:45:00
338	2021-02-09 00:00:00	98	56	Control	08:00:00
339	2023-02-16 00:00:00	157	40	Control	14:45:00
340	2021-02-26 00:00:00	175	22	Reconsulta	06:15:00
341	2023-01-22 00:00:00	23	13	Chequeo	18:30:00
342	2022-05-01 00:00:00	167	99	Valoración inicial	08:45:00
343	2022-12-11 00:00:00	172	94	Reconsulta	07:15:00
344	2022-11-17 00:00:00	64	1	Consulta general	09:15:00
345	2025-02-24 00:00:00	145	52	Control	15:45:00
346	2022-03-20 00:00:00	114	40	Consulta general	09:00:00
347	2023-04-05 00:00:00	159	99	Seguimiento de tratamiento	12:15:00
348	2023-06-07 00:00:00	166	48	Reconsulta	09:45:00
349	2023-05-26 00:00:00	122	98	Valoración inicial	18:30:00
350	2023-12-13 00:00:00	78	44	Urgencia	06:30:00
351	2015-11-11 00:00:00	80	90	Embarazo de Alto riesgo	12:45:00
\.


--
-- Data for Name: appointments_audit; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.appointments_audit (audit_id, id, actionappointment, changed_at, changed_by, before_data, after_data) FROM stdin;
1	351	INSERT	2025-10-14 19:25:06.238469+00	Admin	\N	{"id": 351, "reason": "Urgencia", "doctor_id": 90, "patient_id": 80, "appointment_date": "2015-11-11T00:00:00", "appointment_time": "12:45:00"}
2	351	UPDATE	2025-10-14 19:27:21.254162+00	Admin	{"id": 351, "reason": "Urgencia", "doctor_id": 90, "patient_id": 80, "appointment_date": "2015-11-11T00:00:00", "appointment_time": "12:45:00"}	{"id": 351, "reason": "Embarazo de Alto riesgo", "doctor_id": 90, "patient_id": 80, "appointment_date": "2015-11-11T00:00:00", "appointment_time": "12:45:00"}
\.


--
-- Data for Name: diagnoses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.diagnoses (id, description, patient_id, appointment_id) FROM stdin;
2	Hepatitis aguda	69	2
3	Fractura leve	36	3
4	Diabetes mellitus tipo 2	123	4
5	Alergia	151	5
6	Alergia	12	6
7	Ansiedad	187	7
8	Cistitis	130	8
9	Depresión	193	9
10	Diabetes mellitus tipo 2	26	10
11	Depresión	5	11
12	Migraña	9	12
13	Dermatitis	143	13
14	Gastritis	165	14
15	Obesidad	151	15
16	Asma	114	16
17	Alergia	78	17
18	Caries dental	105	18
19	Dermatitis	113	19
20	Migraña	29	20
21	Insuficiencia renal	107	21
22	Ansiedad	51	22
23	Infección urinaria	10	23
24	Hipertensión arterial	33	24
25	Infección urinaria	76	25
26	Alergia	19	26
27	Obesidad	142	27
28	Asma	133	28
29	Obesidad	66	29
30	Fractura leve	57	30
31	Hipertensión arterial	86	31
32	Alergia	76	32
33	Diabetes mellitus tipo 2	98	33
34	Dermatitis	100	34
35	Alergia	48	35
36	Caries dental	149	36
37	Ansiedad	100	37
38	Insuficiencia renal	169	38
39	Insuficiencia renal	164	39
40	Caries dental	37	40
41	Sinusitis	3	41
42	Hepatitis aguda	47	42
43	Infección respiratoria aguda	109	43
44	Alergia	39	44
45	Ansiedad	185	45
46	Infección urinaria	34	46
47	Bronquitis	130	47
48	Insuficiencia renal	100	48
49	Infección respiratoria aguda	92	49
50	Bronquitis	68	50
51	Infección de piel	47	51
52	Fractura leve	191	52
53	Sinusitis	169	53
54	Infección respiratoria aguda	23	54
55	Alergia	74	55
56	Hipertensión arterial	181	56
57	Hipercolesterolemia	197	57
58	Fractura leve	158	58
59	Diabetes mellitus tipo 2	122	59
60	Fractura leve	107	60
61	Insuficiencia renal	15	61
62	Caries dental	66	62
63	Asma	96	63
64	Ansiedad	2	64
65	Migraña	119	65
66	Hipertensión arterial	95	66
67	Infección respiratoria aguda	78	67
68	Asma	67	68
69	Infección urinaria	85	69
70	Hipercolesterolemia	67	70
71	Gastritis	114	71
72	Hipertensión arterial	112	72
73	Asma	24	73
74	Diabetes mellitus tipo 2	188	74
75	Infección urinaria	44	75
76	Asma	34	76
77	Asma	109	77
78	Caries dental	163	78
79	Fractura leve	9	79
80	Hipercolesterolemia	149	80
81	Dermatitis	40	81
82	Infección urinaria	71	82
83	Hipertensión arterial	170	83
84	Cistitis	84	84
85	Gastritis	90	85
86	Infección urinaria	129	86
87	Alergia	99	87
88	Dermatitis	29	88
89	Hepatitis aguda	169	89
90	Infección urinaria	66	90
91	Migraña	2	91
92	Fractura leve	120	92
93	Cistitis	106	93
94	Infección urinaria	95	94
95	Infección urinaria	187	95
96	Infección de piel	77	96
97	Hepatitis aguda	64	97
98	Insuficiencia renal	102	98
99	Obesidad	74	99
100	Infección respiratoria aguda	57	100
101	Insuficiencia renal	165	101
102	Fractura leve	187	102
103	Asma	69	103
104	Hipertensión arterial	85	104
105	Fractura leve	69	105
106	Infección respiratoria aguda	40	106
107	Alergia	23	107
108	Asma	134	108
109	Sinusitis	152	109
110	Insuficiencia renal	145	110
111	Infección urinaria	53	111
112	Ansiedad	198	112
113	Migraña	194	113
114	Depresión	67	114
115	Hepatitis aguda	1	115
116	Hipertensión arterial	49	116
117	Ansiedad	139	117
118	Insuficiencia renal	31	118
119	Fractura leve	66	119
120	Cistitis	134	120
121	Dermatitis	100	121
122	Infección urinaria	111	122
123	Sinusitis	193	123
124	Infección respiratoria aguda	57	124
125	Hipertensión arterial	6	125
126	Asma	198	126
127	Cistitis	5	127
128	Infección de piel	116	128
129	Insuficiencia renal	82	129
130	Caries dental	55	130
131	Infección respiratoria aguda	119	131
132	Asma	41	132
133	Migraña	118	133
134	Infección de piel	107	134
135	Gastritis	11	135
136	Migraña	137	136
137	Hipertensión arterial	23	137
138	Hipercolesterolemia	184	138
139	Sinusitis	26	139
140	Alergia	195	140
141	Migraña	129	141
142	Hipertensión arterial	75	142
143	Fractura leve	22	143
144	Hipercolesterolemia	39	144
145	Hipercolesterolemia	192	145
146	Hipertensión arterial	155	146
147	Hepatitis aguda	133	147
148	Infección respiratoria aguda	20	148
149	Migraña	152	149
150	Hepatitis aguda	54	150
151	Gastritis	173	151
152	Hipertensión arterial	110	152
153	Hepatitis aguda	186	153
154	Diabetes mellitus tipo 2	24	154
155	Infección respiratoria aguda	166	155
156	Infección de piel	175	156
157	Diabetes mellitus tipo 2	54	157
158	Fractura leve	198	158
159	Dermatitis	116	159
160	Infección de piel	196	160
161	Sinusitis	165	161
162	Infección urinaria	110	162
163	Alergia	21	163
164	Bronquitis	198	164
165	Cistitis	36	165
166	Infección de piel	35	166
167	Alergia	125	167
168	Cistitis	126	168
169	Sinusitis	187	169
170	Infección de piel	138	170
171	Asma	97	171
172	Dermatitis	112	172
173	Gastritis	137	173
174	Dermatitis	99	174
175	Dermatitis	133	175
176	Bronquitis	148	176
177	Bronquitis	99	177
178	Caries dental	140	178
179	Insuficiencia renal	48	179
180	Infección urinaria	57	180
181	Fractura leve	139	181
182	Caries dental	141	182
183	Ansiedad	109	183
184	Obesidad	71	184
185	Fractura leve	86	185
186	Bronquitis	59	186
187	Infección de piel	179	187
188	Diabetes mellitus tipo 2	53	188
189	Cistitis	194	189
190	Hepatitis aguda	63	190
191	Ansiedad	191	191
192	Caries dental	110	192
193	Cistitis	30	193
194	Insuficiencia renal	23	194
195	Hipertensión arterial	150	195
196	Obesidad	119	196
197	Ansiedad	167	197
198	Infección urinaria	3	198
199	Fractura leve	85	199
200	Cistitis	45	200
201	Infección urinaria	84	201
202	Cistitis	149	202
203	Depresión	102	203
204	Asma	195	204
205	Infección urinaria	112	205
206	Obesidad	14	206
207	Ansiedad	68	207
208	Hepatitis aguda	163	208
209	Asma	120	209
210	Fractura leve	139	210
211	Caries dental	180	211
212	Diabetes mellitus tipo 2	139	212
213	Asma	160	213
214	Sinusitis	71	214
215	Caries dental	176	215
216	Sinusitis	119	216
217	Infección respiratoria aguda	147	217
218	Infección respiratoria aguda	16	218
219	Hepatitis aguda	56	219
220	Dermatitis	184	220
221	Alergia	154	221
222	Migraña	133	222
223	Hipercolesterolemia	35	223
224	Bronquitis	74	224
225	Depresión	57	225
226	Depresión	183	226
227	Bronquitis	132	227
228	Hepatitis aguda	24	228
229	Hipertensión arterial	12	229
230	Hipertensión arterial	102	230
231	Hepatitis aguda	11	231
232	Insuficiencia renal	142	232
233	Migraña	102	233
234	Depresión	39	234
235	Ansiedad	128	235
236	Fractura leve	186	236
237	Hepatitis aguda	32	237
238	Gastritis	121	238
239	Infección de piel	30	239
240	Hipertensión arterial	15	240
241	Infección urinaria	158	241
242	Hepatitis aguda	36	242
243	Insuficiencia renal	30	243
244	Ansiedad	188	244
245	Hipercolesterolemia	38	245
246	Asma	121	246
247	Infección de piel	58	247
248	Hepatitis aguda	92	248
249	Infección de piel	77	249
250	Sinusitis	113	250
251	Insuficiencia renal	11	251
252	Infección de piel	31	252
253	Fractura leve	77	253
254	Asma	194	254
255	Migraña	78	255
256	Ansiedad	79	256
257	Insuficiencia renal	79	257
258	Depresión	98	258
259	Hepatitis aguda	188	259
260	Alergia	16	260
261	Diabetes mellitus tipo 2	60	261
262	Cistitis	175	262
263	Depresión	58	263
264	Fractura leve	88	264
265	Hipercolesterolemia	1	265
266	Diabetes mellitus tipo 2	100	266
267	Asma	138	267
268	Infección respiratoria aguda	139	268
269	Cistitis	175	269
270	Gastritis	122	270
271	Infección de piel	55	271
272	Fractura leve	105	272
273	Caries dental	32	273
274	Infección respiratoria aguda	191	274
275	Hipertensión arterial	136	275
276	Depresión	165	276
277	Infección de piel	132	277
278	Caries dental	179	278
279	Infección respiratoria aguda	43	279
280	Hipercolesterolemia	148	280
281	Bronquitis	69	281
282	Caries dental	102	282
283	Dermatitis	130	283
284	Hepatitis aguda	118	284
285	Hepatitis aguda	1	285
286	Caries dental	3	286
287	Obesidad	101	287
288	Cistitis	94	288
289	Bronquitis	14	289
290	Sinusitis	121	290
291	Ansiedad	122	291
292	Infección de piel	193	292
293	Insuficiencia renal	192	293
294	Hipertensión arterial	148	294
295	Hipercolesterolemia	63	295
296	Insuficiencia renal	193	296
297	Cistitis	53	297
298	Hipertensión arterial	38	298
299	Caries dental	70	299
300	Infección respiratoria aguda	138	300
301	Caries dental	23	301
302	Gastritis	76	302
303	Bronquitis	169	303
304	Asma	135	304
305	Sinusitis	134	305
306	Gastritis	1	306
307	Dermatitis	79	307
308	Alergia	200	308
309	Ansiedad	151	309
310	Migraña	110	310
311	Hepatitis aguda	94	311
312	Hipertensión arterial	11	312
313	Insuficiencia renal	178	313
314	Hipercolesterolemia	41	314
315	Fractura leve	93	315
316	Caries dental	181	316
317	Insuficiencia renal	192	317
318	Insuficiencia renal	71	318
319	Alergia	26	319
320	Fractura leve	123	320
321	Infección respiratoria aguda	156	321
322	Fractura leve	40	322
323	Obesidad	163	323
324	Gastritis	11	324
325	Infección urinaria	113	325
326	Gastritis	24	326
327	Insuficiencia renal	47	327
328	Infección urinaria	68	328
329	Alergia	51	329
330	Migraña	167	330
331	Alergia	194	331
332	Cistitis	70	332
333	Infección respiratoria aguda	19	333
334	Hipercolesterolemia	198	334
335	Cistitis	196	335
336	Infección respiratoria aguda	185	336
337	Depresión	143	337
338	Infección de piel	98	338
339	Infección urinaria	157	339
340	Diabetes mellitus tipo 2	175	340
341	Depresión	23	341
342	Hepatitis aguda	167	342
343	Infección urinaria	172	343
344	Fractura leve	64	344
345	Hipercolesterolemia	145	345
346	Depresión	114	346
347	Infección urinaria	159	347
348	Migraña	166	348
349	Fractura leve	122	349
350	Hipertensión arterial	78	350
1	Ansiedad	51	1
\.


--
-- Data for Name: diagnoses_audit; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.diagnoses_audit (audit_id, id, actiondiagnosis, changed_at, changed_by, before_data, after_data) FROM stdin;
1	1	UPDATE	2025-10-14 03:07:56.228973+00	Admin	{"id": 1, "patient_id": 51, "description": "Ansiedad", "appointment_id": 1}	{"id": 1, "patient_id": 51, "description": "Sexo", "appointment_id": 1}
2	1	UPDATE	2025-10-14 03:08:35.283245+00	Admin	{"id": 1, "patient_id": 51, "description": "Sexo", "appointment_id": 1}	{"id": 1, "patient_id": 51, "description": "Ansiedad", "appointment_id": 1}
\.


--
-- Data for Name: doctors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.doctors (id, name, last_name, telephone, email, specialty_id) FROM stdin;
1	Fernando	Gómez	+5738189385	fernando.gómez1@clinica.local	39
2	Carolina	Rodríguez	+5733968654	carolina.rodríguez2@clinica.local	37
3	Anderson	Díaz	+5734900768	anderson.díaz3@clinica.local	31
4	Catalina	Flórez	+5730457078	catalina.flórez4@clinica.local	19
5	Catalina	Torres	+5732616249	catalina.torres5@clinica.local	44
6	Sandra	Flórez	+5735748885	sandra.flórez6@clinica.local	50
7	Camila	Torres	+5730509891	camila.torres7@clinica.local	60
8	Daniel	Díaz	+5730034622	daniel.díaz8@clinica.local	69
9	Daniel	Ríos	+5733749332	daniel.ríos9@clinica.local	35
10	Luis	Pérez	+5730228207	luis.pérez10@clinica.local	44
11	Andrea	Mendoza	+5731619978	andrea.mendoza11@clinica.local	97
12	Alejandro	Torres	+5730726374	alejandro.torres12@clinica.local	88
13	María	Martínez	+5733859886	maría.martínez13@clinica.local	36
14	Lucía	Rodríguez	+5733894921	lucía.rodríguez14@clinica.local	78
15	Daniel	Ramírez	+5732353797	daniel.ramírez15@clinica.local	97
16	Diego	Rodríguez	+5739036353	diego.rodríguez16@clinica.local	19
17	David	Rodríguez	+5731759676	david.rodríguez17@clinica.local	56
18	Jorge	Díaz	+5735020000	jorge.díaz18@clinica.local	10
19	Valentina	Gómez	+5739725475	valentina.gómez19@clinica.local	69
20	Daniel	Rodríguez	+5732922640	daniel.rodríguez20@clinica.local	22
21	Lucía	Castro	+5738815469	lucía.castro21@clinica.local	14
22	Luis	Díaz	+5731315255	luis.díaz22@clinica.local	11
23	Marta	Cruz	+5730526020	marta.cruz23@clinica.local	40
24	Héctor	Suárez	+5738295400	héctor.suárez24@clinica.local	10
25	Daniel	Castro	+5733180250	daniel.castro25@clinica.local	32
26	Isabella	Rodríguez	+5739473538	isabella.rodríguez26@clinica.local	25
27	Alejandro	Ríos	+5733371957	alejandro.ríos27@clinica.local	7
28	Ana	Castillo	+5732356831	ana.castillo28@clinica.local	81
29	Paola	Jiménez	+5736798539	paola.jiménez29@clinica.local	87
30	Ana	Jiménez	+5734395453	ana.jiménez30@clinica.local	90
31	Samuel	Martínez	+5730075828	samuel.martínez31@clinica.local	9
32	Sofía	Cruz	+5730709359	sofía.cruz32@clinica.local	95
33	Camila	Castillo	+5735466493	camila.castillo33@clinica.local	73
34	José	Jiménez	+5739403637	josé.jiménez34@clinica.local	15
35	Fernando	Vargas	+5730664288	fernando.vargas35@clinica.local	47
36	Óscar	Suárez	+5734718578	óscar.suárez36@clinica.local	93
37	Daniel	Díaz	+5737270219	daniel.díaz37@clinica.local	35
38	Camilo	Torres	+5730729208	camilo.torres38@clinica.local	81
39	Carolina	Martínez	+5734239744	carolina.martínez39@clinica.local	62
40	Natalia	Sánchez	+5735075598	natalia.sánchez40@clinica.local	37
41	Paola	Mendoza	+5733550871	paola.mendoza41@clinica.local	20
42	Juan	Cruz	+5732261750	juan.cruz42@clinica.local	92
43	Sofía	Díaz	+5739870946	sofía.díaz43@clinica.local	99
44	Alejandro	González	+5738236694	alejandro.gonzález44@clinica.local	9
45	Diana	Ríos	+5733146665	diana.ríos45@clinica.local	87
46	Marta	Martínez	+5733626875	marta.martínez46@clinica.local	28
47	Isabella	Ramírez	+5730003964	isabella.ramírez47@clinica.local	77
48	Sergio	Rojas	+5738459617	sergio.rojas48@clinica.local	59
49	Lucía	Mendoza	+5731065461	lucía.mendoza49@clinica.local	90
50	Juan	Castillo	+5733642696	juan.castillo50@clinica.local	66
51	Juliana	Sánchez	+5733986038	juliana.sánchez51@clinica.local	14
52	Lucía	Rodríguez	+5738695030	lucía.rodríguez52@clinica.local	30
53	Marta	Martínez	+5737503534	marta.martínez53@clinica.local	72
54	Ricardo	Flórez	+5736063593	ricardo.flórez54@clinica.local	34
55	Daniel	Flórez	+5732450637	daniel.flórez55@clinica.local	21
56	Samuel	Ruiz	+5735474076	samuel.ruiz56@clinica.local	12
57	José	Ruiz	+5739834591	josé.ruiz57@clinica.local	50
58	Samuel	Ríos	+5738107849	samuel.ríos58@clinica.local	21
59	Fernando	Castillo	+5739063745	fernando.castillo59@clinica.local	29
60	Patricia	Torres	+5733160916	patricia.torres60@clinica.local	6
61	María	Ruiz	+5735967035	maría.ruiz61@clinica.local	33
62	Juliana	Ruiz	+5738852460	juliana.ruiz62@clinica.local	56
63	Diana	Díaz	+5734801197	diana.díaz63@clinica.local	45
64	Héctor	Rojas	+5731170472	héctor.rojas64@clinica.local	93
65	Andrés	Ruiz	+5731457403	andrés.ruiz65@clinica.local	68
66	Paola	Cruz	+5732337776	paola.cruz66@clinica.local	87
67	Eduardo	Cruz	+5730118236	eduardo.cruz67@clinica.local	97
68	Valentina	Sánchez	+5738801010	valentina.sánchez68@clinica.local	15
69	Valentina	Castro	+5738655379	valentina.castro69@clinica.local	33
70	Lorena	Vargas	+5733736431	lorena.vargas70@clinica.local	61
71	Lorena	Jiménez	+5731470246	lorena.jiménez71@clinica.local	25
72	Patricia	Mendoza	+5738669247	patricia.mendoza72@clinica.local	29
73	Mauricio	Rodríguez	+5734653748	mauricio.rodríguez73@clinica.local	41
74	Mauricio	Díaz	+5739691786	mauricio.díaz74@clinica.local	8
75	Valentina	Gómez	+5733313732	valentina.gómez75@clinica.local	2
76	Valentina	Cruz	+5733989441	valentina.cruz76@clinica.local	50
77	José	Torres	+5736169245	josé.torres77@clinica.local	21
78	Óscar	Castillo	+5730813303	óscar.castillo78@clinica.local	57
79	Anderson	Díaz	+5733406448	anderson.díaz79@clinica.local	20
80	Carlos	Ríos	+5732390457	carlos.ríos80@clinica.local	20
81	Valentina	Díaz	+5735962825	valentina.díaz81@clinica.local	98
82	Sofía	Ruiz	+5734128793	sofía.ruiz82@clinica.local	43
83	Lorena	Castillo	+5734663507	lorena.castillo83@clinica.local	6
84	David	Vargas	+5730055732	david.vargas84@clinica.local	64
85	Natalia	Ríos	+5733827105	natalia.ríos85@clinica.local	63
86	Luis	González	+5731241347	luis.gonzález86@clinica.local	61
87	Juliana	Pérez	+5738522227	juliana.pérez87@clinica.local	58
88	Camilo	Castro	+5732795944	camilo.castro88@clinica.local	18
89	Laura	Gómez	+5739362506	laura.gómez89@clinica.local	38
90	Óscar	Flórez	+5738133353	óscar.flórez90@clinica.local	75
91	Laura	Rodríguez	+5733513305	laura.rodríguez91@clinica.local	5
92	Lorena	González	+5733475036	lorena.gonzález92@clinica.local	73
93	Sandra	Jiménez	+5737101051	sandra.jiménez93@clinica.local	7
94	José	Sánchez	+5730518883	josé.sánchez94@clinica.local	98
95	Valentina	Flórez	+5735101998	valentina.flórez95@clinica.local	72
96	Ricardo	Flórez	+5738915300	ricardo.flórez96@clinica.local	72
97	David	Torres	+5732418283	david.torres97@clinica.local	83
98	Lorena	Gómez	+5733792691	lorena.gómez98@clinica.local	100
99	Natalia	Castillo	+5733703745	natalia.castillo99@clinica.local	32
100	Carlos	Martínez	+5730070837	carlos.martínez100@clinica.local	68
\.


--
-- Data for Name: doctors_audit; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.doctors_audit (audit_id, id, actiondoctor, changed_at, changed_by, before_data, after_data) FROM stdin;
\.


--
-- Data for Name: medicines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.medicines (id, name, presentation, dose) FROM stdin;
1	Paracetamol - tabletas 500 mg	tabletas 500 mg	500 mg
2	Ibuprofeno - tabletas 250 mg	tabletas 250 mg	250 mg
3	Amoxicilina - jarabe 100 ml	jarabe 100 ml	según indicación
4	Azitromicina - inyección 1 ml	inyección 1 ml	según indicación
5	Omeprazol - crema 30 g	crema 30 g	según indicación
6	Metformina - ampolla 2 ml	ampolla 2 ml	según indicación
7	Losartán - comprimidos 50 mg	comprimidos 50 mg	50 mg
8	Atorvastatina - jarabe 60 ml	jarabe 60 ml	según indicación
9	Insulina NPH - tabletas 500 mg	tabletas 500 mg	500 mg
10	Salbutamol - tabletas 250 mg	tabletas 250 mg	250 mg
11	Ciprofloxacino - jarabe 100 ml	jarabe 100 ml	según indicación
12	Diazepam - inyección 1 ml	inyección 1 ml	según indicación
13	Loratadina - crema 30 g	crema 30 g	según indicación
14	Cetirizina - ampolla 2 ml	ampolla 2 ml	según indicación
15	Naproxeno - comprimidos 50 mg	comprimidos 50 mg	50 mg
16	Ácido Acetilsalicílico - jarabe 60 ml	jarabe 60 ml	según indicación
17	Prednisona - tabletas 500 mg	tabletas 500 mg	500 mg
18	Ranitidina - tabletas 250 mg	tabletas 250 mg	250 mg
19	Clonazepam - jarabe 100 ml	jarabe 100 ml	según indicación
20	Levotiroxina - inyección 1 ml	inyección 1 ml	según indicación
21	Fluconazol - crema 30 g	crema 30 g	según indicación
22	Albendazol - ampolla 2 ml	ampolla 2 ml	según indicación
23	Metronidazol - comprimidos 50 mg	comprimidos 50 mg	50 mg
24	Clindamicina - jarabe 60 ml	jarabe 60 ml	según indicación
25	Tramadol - tabletas 500 mg	tabletas 500 mg	500 mg
26	Furosemida - tabletas 250 mg	tabletas 250 mg	250 mg
27	Espironolactona - jarabe 100 ml	jarabe 100 ml	según indicación
28	Amlodipino - inyección 1 ml	inyección 1 ml	según indicación
29	Enalapril - crema 30 g	crema 30 g	según indicación
30	Carvedilol - ampolla 2 ml	ampolla 2 ml	según indicación
31	Bisoprolol - comprimidos 50 mg	comprimidos 50 mg	50 mg
32	Diclofenaco - jarabe 60 ml	jarabe 60 ml	según indicación
33	Hidroclorotiazida - tabletas 500 mg	tabletas 500 mg	500 mg
34	Vitamina C - tabletas 250 mg	tabletas 250 mg	250 mg
35	Vitamina D - jarabe 100 ml	jarabe 100 ml	según indicación
36	Calcio - inyección 1 ml	inyección 1 ml	según indicación
37	Hierro - crema 30 g	crema 30 g	según indicación
38	Propranolol - ampolla 2 ml	ampolla 2 ml	según indicación
39	Ketorolaco - comprimidos 50 mg	comprimidos 50 mg	50 mg
40	Oseltamivir - jarabe 60 ml	jarabe 60 ml	según indicación
41	Fluoxetina - tabletas 500 mg	tabletas 500 mg	500 mg
42	Sertralina - tabletas 250 mg	tabletas 250 mg	250 mg
43	Amiodarona - jarabe 100 ml	jarabe 100 ml	según indicación
44	Nifedipino - inyección 1 ml	inyección 1 ml	según indicación
45	Clopidogrel - crema 30 g	crema 30 g	según indicación
46	Claritromicina - ampolla 2 ml	ampolla 2 ml	según indicación
47	Doxiciclina - comprimidos 50 mg	comprimidos 50 mg	50 mg
48	Budesonida - jarabe 60 ml	jarabe 60 ml	según indicación
49	Ivermectina - tabletas 500 mg	tabletas 500 mg	500 mg
50	Mebendazol - tabletas 250 mg	tabletas 250 mg	250 mg
51	Ketoconazol - jarabe 100 ml	jarabe 100 ml	según indicación
52	Salicilato de metilo - inyección 1 ml	inyección 1 ml	según indicación
53	Spironolactona - crema 30 g	crema 30 g	según indicación
54	Meloxicam - ampolla 2 ml	ampolla 2 ml	según indicación
55	Ondansetrón - comprimidos 50 mg	comprimidos 50 mg	50 mg
56	Levofloxacino - jarabe 60 ml	jarabe 60 ml	según indicación
57	Fenitoína - tabletas 500 mg	tabletas 500 mg	500 mg
58	Paracetamol - tabletas 250 mg	tabletas 250 mg	250 mg
59	Ibuprofeno - jarabe 100 ml	jarabe 100 ml	según indicación
60	Amoxicilina - inyección 1 ml	inyección 1 ml	según indicación
61	Azitromicina - crema 30 g	crema 30 g	según indicación
62	Omeprazol - ampolla 2 ml	ampolla 2 ml	según indicación
63	Metformina - comprimidos 50 mg	comprimidos 50 mg	50 mg
64	Losartán - jarabe 60 ml	jarabe 60 ml	según indicación
65	Atorvastatina - tabletas 500 mg	tabletas 500 mg	500 mg
66	Insulina NPH - tabletas 250 mg	tabletas 250 mg	250 mg
67	Salbutamol - jarabe 100 ml	jarabe 100 ml	según indicación
68	Ciprofloxacino - inyección 1 ml	inyección 1 ml	según indicación
69	Diazepam - crema 30 g	crema 30 g	según indicación
70	Loratadina - ampolla 2 ml	ampolla 2 ml	según indicación
71	Cetirizina - comprimidos 50 mg	comprimidos 50 mg	50 mg
72	Naproxeno - jarabe 60 ml	jarabe 60 ml	según indicación
73	Ácido Acetilsalicílico - tabletas 500 mg	tabletas 500 mg	500 mg
74	Prednisona - tabletas 250 mg	tabletas 250 mg	250 mg
75	Ranitidina - jarabe 100 ml	jarabe 100 ml	según indicación
76	Clonazepam - inyección 1 ml	inyección 1 ml	según indicación
77	Levotiroxina - crema 30 g	crema 30 g	según indicación
78	Fluconazol - ampolla 2 ml	ampolla 2 ml	según indicación
79	Albendazol - comprimidos 50 mg	comprimidos 50 mg	50 mg
80	Metronidazol - jarabe 60 ml	jarabe 60 ml	según indicación
81	Clindamicina - tabletas 500 mg	tabletas 500 mg	500 mg
82	Tramadol - tabletas 250 mg	tabletas 250 mg	250 mg
83	Furosemida - jarabe 100 ml	jarabe 100 ml	según indicación
84	Espironolactona - inyección 1 ml	inyección 1 ml	según indicación
85	Amlodipino - crema 30 g	crema 30 g	según indicación
86	Enalapril - ampolla 2 ml	ampolla 2 ml	según indicación
87	Carvedilol - comprimidos 50 mg	comprimidos 50 mg	50 mg
88	Bisoprolol - jarabe 60 ml	jarabe 60 ml	según indicación
89	Diclofenaco - tabletas 500 mg	tabletas 500 mg	500 mg
90	Hidroclorotiazida - tabletas 250 mg	tabletas 250 mg	250 mg
91	Vitamina C - jarabe 100 ml	jarabe 100 ml	según indicación
92	Vitamina D - inyección 1 ml	inyección 1 ml	según indicación
93	Calcio - crema 30 g	crema 30 g	según indicación
94	Hierro - ampolla 2 ml	ampolla 2 ml	según indicación
95	Propranolol - comprimidos 50 mg	comprimidos 50 mg	50 mg
96	Ketorolaco - jarabe 60 ml	jarabe 60 ml	según indicación
97	Oseltamivir - tabletas 500 mg	tabletas 500 mg	500 mg
98	Fluoxetina - tabletas 250 mg	tabletas 250 mg	250 mg
99	Sertralina - jarabe 100 ml	jarabe 100 ml	según indicación
100	Amiodarona - inyección 1 ml	inyección 1 ml	según indicación
101	Nifedipino - crema 30 g	crema 30 g	según indicación
102	Clopidogrel - ampolla 2 ml	ampolla 2 ml	según indicación
103	Claritromicina - comprimidos 50 mg	comprimidos 50 mg	50 mg
104	Doxiciclina - jarabe 60 ml	jarabe 60 ml	según indicación
105	Budesonida - tabletas 500 mg	tabletas 500 mg	500 mg
106	Ivermectina - tabletas 250 mg	tabletas 250 mg	250 mg
107	Mebendazol - jarabe 100 ml	jarabe 100 ml	según indicación
108	Ketoconazol - inyección 1 ml	inyección 1 ml	según indicación
109	Salicilato de metilo - crema 30 g	crema 30 g	según indicación
110	Spironolactona - ampolla 2 ml	ampolla 2 ml	según indicación
111	Meloxicam - comprimidos 50 mg	comprimidos 50 mg	50 mg
112	Ondansetrón - jarabe 60 ml	jarabe 60 ml	según indicación
113	Levofloxacino - tabletas 500 mg	tabletas 500 mg	500 mg
114	Fenitoína - tabletas 250 mg	tabletas 250 mg	250 mg
115	Paracetamol - jarabe 100 ml	jarabe 100 ml	según indicación
116	Ibuprofeno - inyección 1 ml	inyección 1 ml	según indicación
117	Amoxicilina - crema 30 g	crema 30 g	según indicación
118	Azitromicina - ampolla 2 ml	ampolla 2 ml	según indicación
119	Omeprazol - comprimidos 50 mg	comprimidos 50 mg	50 mg
120	Metformina - jarabe 60 ml	jarabe 60 ml	según indicación
121	Losartán - tabletas 500 mg	tabletas 500 mg	500 mg
122	Atorvastatina - tabletas 250 mg	tabletas 250 mg	250 mg
123	Insulina NPH - jarabe 100 ml	jarabe 100 ml	según indicación
124	Salbutamol - inyección 1 ml	inyección 1 ml	según indicación
125	Ciprofloxacino - crema 30 g	crema 30 g	según indicación
126	Diazepam - ampolla 2 ml	ampolla 2 ml	según indicación
127	Loratadina - comprimidos 50 mg	comprimidos 50 mg	50 mg
128	Cetirizina - jarabe 60 ml	jarabe 60 ml	según indicación
129	Naproxeno - tabletas 500 mg	tabletas 500 mg	500 mg
130	Ácido Acetilsalicílico - tabletas 250 mg	tabletas 250 mg	250 mg
131	Prednisona - jarabe 100 ml	jarabe 100 ml	según indicación
132	Ranitidina - inyección 1 ml	inyección 1 ml	según indicación
133	Clonazepam - crema 30 g	crema 30 g	según indicación
134	Levotiroxina - ampolla 2 ml	ampolla 2 ml	según indicación
135	Fluconazol - comprimidos 50 mg	comprimidos 50 mg	50 mg
136	Albendazol - jarabe 60 ml	jarabe 60 ml	según indicación
137	Metronidazol - tabletas 500 mg	tabletas 500 mg	500 mg
138	Clindamicina - tabletas 250 mg	tabletas 250 mg	250 mg
139	Tramadol - jarabe 100 ml	jarabe 100 ml	según indicación
140	Furosemida - inyección 1 ml	inyección 1 ml	según indicación
141	Espironolactona - crema 30 g	crema 30 g	según indicación
142	Amlodipino - ampolla 2 ml	ampolla 2 ml	según indicación
143	Enalapril - comprimidos 50 mg	comprimidos 50 mg	50 mg
144	Carvedilol - jarabe 60 ml	jarabe 60 ml	según indicación
145	Bisoprolol - tabletas 500 mg	tabletas 500 mg	500 mg
146	Diclofenaco - tabletas 250 mg	tabletas 250 mg	250 mg
147	Hidroclorotiazida - jarabe 100 ml	jarabe 100 ml	según indicación
148	Vitamina C - inyección 1 ml	inyección 1 ml	según indicación
149	Vitamina D - crema 30 g	crema 30 g	según indicación
150	Calcio - ampolla 2 ml	ampolla 2 ml	según indicación
\.


--
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.patients (id, name, last_name, birth_date, gender, address, telephone, age) FROM stdin;
1	Diego	Martínez Castillo	1957-11-27	M	Calle 172 #129-44, Tunja	+5738542916	67
2	Diego	Ramírez Martínez	1972-01-25	M	Calle 106 #99-6, Cartagena	+5734930670	53
3	Valentina	Rodríguez Rojas	1957-09-01	F	Calle 205 #31-77, Cartagena	+5736875406	68
4	Edison	Pérez Jiménez	1960-03-06	M	Calle 295 #144-44, Santa Marta	+5731916596	65
5	Ana	Mendoza Pérez	2018-08-26	F	Calle 132 #196-24, Valledupar	+5738383622	7
6	Patricia	Jiménez Gómez	1953-06-11	F	Calle 6 #77-32, Bucaramanga	+5737469294	72
7	Valentina	Torres Martínez	2000-04-27	F	Calle 35 #5-61, Sincelejo	+5732111443	25
8	Paola	Flórez Ruiz	1965-09-07	F	Calle 231 #134-34, Valledupar	+5732901079	60
9	Lorena	Mendoza Rojas	1960-04-02	F	Calle 172 #37-66, Pereira	+5731225019	65
10	Daniel	Ruiz Cruz	1984-04-03	M	Calle 71 #122-51, Ibagué	+5731088062	41
11	José	Ramírez Cruz	1939-09-29	M	Calle 286 #17-72, Bogotá	+5734775353	86
12	Ana	Ramírez Sánchez	1999-09-27	F	Calle 150 #46-48, Bogotá	+5733540485	26
13	Claudia	Suárez Cruz	1961-06-03	F	Calle 127 #9-8, Bogotá	+5732780324	64
14	Camilo	Suárez Jiménez	2016-05-04	M	Calle 242 #59-66, Ibagué	+5738209627	9
15	Laura	Rojas Jiménez	1997-02-18	F	Calle 277 #19-44, Pereira	+5732781167	28
16	Anderson	Jiménez Castro	1936-08-18	M	Calle 15 #153-46, Manizales	+5734566186	89
17	Andrea	Mendoza Díaz	1985-02-27	F	Calle 8 #97-77, Sincelejo	+5730455020	40
18	Lucía	Ríos González	2010-07-16	F	Calle 199 #103-10, Bogotá	+5737661478	15
19	Juliana	Díaz Mendoza	1970-04-10	F	Calle 65 #21-19, Bogotá	+5732110222	55
20	Lucía	González Vargas	1936-01-24	F	Calle 232 #130-69, Santa Marta	+5733628686	89
21	Laura	González Ruiz	1965-08-11	F	Calle 40 #77-38, Cartagena	+5736089428	60
22	Lucía	Rodríguez Ruiz	1932-01-21	F	Calle 87 #42-16, Ibagué	+5739859629	93
23	Camilo	Rodríguez Martínez	1951-02-20	M	Calle 162 #30-42, Cali	+5739673177	74
24	Óscar	Jiménez Torres	1930-03-18	M	Calle 35 #92-30, Bogotá	+5737897232	95
25	Óscar	Ríos Castillo	2004-10-04	M	Calle 264 #138-18, Manizales	+5730210689	20
26	Eduardo	Martínez Suárez	1968-03-28	M	Calle 108 #47-55, Medellín	+5731940510	57
27	Jairo	Ramírez Díaz	1951-02-07	M	Calle 209 #68-53, Ibagué	+5734383866	74
28	William	Gómez Mendoza	1932-11-07	M	Calle 196 #68-46, Manizales	+5731323973	92
29	Camilo	Flórez González	1942-05-16	M	Calle 88 #126-34, Ibagué	+5738994413	83
30	Ricardo	Flórez Flórez	2014-07-16	M	Calle 194 #138-78, Medellín	+5738994933	11
31	Sandra	Ruiz Mendoza	2010-11-06	F	Calle 218 #145-15, Cúcuta	+5734993863	14
32	Camilo	Vargas Flórez	1984-10-15	M	Calle 256 #87-9, Tunja	+5736989234	40
33	Carlos	Ramírez Castro	2003-10-24	M	Calle 180 #41-49, Ibagué	+5733974135	21
34	Ricardo	Flórez Rodríguez	2015-09-27	M	Calle 276 #136-63, Riohacha	+5733349024	10
35	José	González Pérez	1967-02-18	M	Calle 120 #104-7, Cali	+5731605805	58
36	Natalia	Ruiz Jiménez	1956-06-03	F	Calle 138 #98-21, Neiva	+5736516724	69
37	Óscar	Jiménez Vargas	1981-10-18	M	Calle 73 #176-35, Pereira	+5734937129	43
38	Lucía	Ruiz Castillo	1984-01-21	F	Calle 114 #191-38, Pereira	+5733690511	41
39	Luis	Díaz Ruiz	1988-12-11	M	Calle 12 #137-70, Santa Marta	+5732715132	36
40	Jorge	Vargas Cruz	1982-11-25	M	Calle 245 #155-72, Cartagena	+5739182283	42
41	Luis	Mendoza Gómez	1949-11-08	M	Calle 125 #76-38, Santa Marta	+5738407995	75
42	Sergio	González Flórez	1982-11-01	M	Calle 130 #30-23, Sincelejo	+5739754796	42
43	Ana	Ríos Cruz	2011-03-30	F	Calle 158 #184-84, Riohacha	+5731124064	14
44	Jorge	Castro Castillo	1939-07-15	M	Calle 207 #165-15, Manizales	+5733037033	86
45	Lorena	Cruz Martínez	1957-06-11	F	Calle 228 #33-31, Pereira	+5737646841	68
46	Diana	Castillo Suárez	1944-06-12	F	Calle 5 #184-15, Bucaramanga	+5736263727	81
47	Mauricio	Díaz Torres	1985-06-13	M	Calle 174 #72-88, Medellín	+5730128257	40
48	Sergio	González González	1985-05-05	M	Calle 26 #7-28, Manizales	+5739125543	40
49	Carlos	Ríos Díaz	1949-01-02	M	Calle 294 #183-84, Neiva	+5735176777	76
50	María	Flórez González	1943-11-23	F	Calle 143 #3-56, Riohacha	+5731851044	81
51	Camila	Flórez Jiménez	1932-03-15	F	Calle 94 #28-22, Manizales	+5735995738	93
52	María	Castro Ríos	1950-06-16	F	Calle 104 #135-42, Bucaramanga	+5737701926	75
53	Valentina	Martínez Suárez	1971-12-12	F	Calle 288 #177-43, Barranquilla	+5735505811	53
54	Anderson	Ruiz Torres	1965-02-28	M	Calle 1 #192-17, Pereira	+5734811929	60
55	Luis	Rojas Rodríguez	2013-06-09	M	Calle 110 #198-2, Medellín	+5733939350	12
56	Marta	Jiménez Torres	1958-12-24	F	Calle 100 #156-13, Sincelejo	+5732231506	66
57	Andrés	Díaz Jiménez	1991-07-17	M	Calle 39 #99-52, Manizales	+5733921146	34
58	Claudia	Castillo Castro	1945-10-04	F	Calle 289 #61-85, Tunja	+5737680171	79
59	Juan	Vargas Gómez	1937-10-29	M	Calle 287 #157-74, Santa Marta	+5732528080	87
60	Mauricio	Castro Castro	1982-04-30	M	Calle 256 #49-24, Cartagena	+5732912986	43
61	Marta	Gómez Rodríguez	1934-03-03	F	Calle 221 #177-14, Neiva	+5737009250	91
62	Daniel	Cruz Gómez	1936-02-24	M	Calle 299 #56-10, Medellín	+5736864917	89
63	Edison	Suárez Cruz	2005-10-25	M	Calle 145 #150-46, Pereira	+5735789280	19
64	Carlos	Rojas Martínez	2009-07-24	M	Calle 174 #118-50, Neiva	+5736465818	16
65	Paola	Sánchez Cruz	1973-10-16	F	Calle 272 #107-48, Barranquilla	+5731892985	51
66	Luis	Jiménez Ramírez	1984-10-15	M	Calle 219 #33-34, Bucaramanga	+5731870035	40
67	Diana	Vargas Vargas	1938-02-01	F	Calle 122 #104-89, Manizales	+5733122945	87
68	Camila	Castillo Rodríguez	1990-05-14	F	Calle 182 #25-90, Pereira	+5732999707	35
69	María	Díaz Ramírez	2000-09-04	F	Calle 114 #26-80, Neiva	+5734077438	25
70	Camilo	Torres Suárez	1946-04-19	M	Calle 295 #12-18, Pereira	+5730972599	79
71	Andrés	Sánchez Cruz	1984-01-28	M	Calle 172 #195-40, Medellín	+5734580836	41
72	Eduardo	Vargas Torres	2003-04-27	M	Calle 127 #129-33, Manizales	+5733917994	22
73	William	Pérez Flórez	1985-07-14	M	Calle 3 #22-62, Cúcuta	+5738259030	40
74	William	Ríos Mendoza	2000-01-04	M	Calle 267 #90-11, Bogotá	+5736653056	25
75	Camila	Gómez Pérez	1995-05-29	F	Calle 57 #15-71, Bucaramanga	+5733057384	30
76	Juliana	Castillo Díaz	2016-12-09	F	Calle 183 #67-81, Bucaramanga	+5737003891	8
77	Paola	Rojas Rodríguez	1946-11-27	F	Calle 84 #42-87, Medellín	+5732477826	78
78	Ricardo	González Mendoza	2018-08-04	M	Calle 289 #121-19, Valledupar	+5734548122	7
79	Juan	Ramírez Pérez	2012-07-24	M	Calle 90 #48-35, Valledupar	+5735495959	13
80	Laura	Rodríguez Rodríguez	2003-08-22	F	Calle 210 #73-62, Manizales	+5736098322	22
81	Mauricio	Sánchez Pérez	1974-06-01	M	Calle 86 #74-30, Cali	+5733580896	51
82	Natalia	Ramírez Torres	1941-09-07	F	Calle 83 #184-48, Bucaramanga	+5734238470	84
83	Anderson	Jiménez Jiménez	1941-11-19	M	Calle 164 #40-85, Neiva	+5732333210	83
84	Lucía	Vargas González	1997-01-20	F	Calle 226 #88-62, Pereira	+5733100396	28
85	Jorge	González Flórez	1965-11-17	M	Calle 268 #16-76, Riohacha	+5731114943	59
86	Ana	Castro Díaz	1947-08-24	F	Calle 13 #56-70, Riohacha	+5738786827	78
87	Patricia	Jiménez Ríos	1944-03-10	F	Calle 250 #70-83, Cali	+5738085845	81
88	Sofía	Torres González	2001-08-21	F	Calle 268 #144-31, Tunja	+5739406281	24
89	Carlos	Jiménez Gómez	1991-07-19	M	Calle 9 #13-90, Sincelejo	+5737479314	34
90	Patricia	Díaz González	1997-05-05	F	Calle 167 #166-64, Barranquilla	+5732608047	28
91	Valentina	Mendoza Martínez	1935-08-13	F	Calle 158 #111-40, Tunja	+5736228343	90
92	Patricia	Jiménez Gómez	1939-04-20	F	Calle 210 #116-67, Bucaramanga	+5732349547	86
93	Alvaro	Martínez Díaz	2014-11-02	M	Calle 113 #162-1, Cúcuta	+5734445910	10
94	Andrea	Vargas Castro	2007-10-07	F	Calle 77 #192-64, Bogotá	+5733981312	17
95	Patricia	Flórez Martínez	1976-02-05	F	Calle 158 #118-73, Cúcuta	+5738316738	49
96	Paola	González Ríos	1961-11-10	F	Calle 217 #43-82, Neiva	+5739715777	63
97	Laura	Castro González	1994-11-09	F	Calle 30 #196-30, Medellín	+5739990377	30
98	Paola	Jiménez Suárez	1999-07-29	F	Calle 241 #157-33, Sincelejo	+5739305579	26
99	Edison	Torres Flórez	1970-12-07	M	Calle 266 #16-56, Valledupar	+5730682757	54
100	Anderson	Cruz Castillo	1939-10-08	M	Calle 119 #84-20, Manizales	+5731976530	85
101	Sergio	Rodríguez Martínez	1982-08-04	M	Calle 156 #48-81, Cúcuta	+5734779377	43
102	Ricardo	Ruiz Flórez	1992-04-01	M	Calle 132 #35-17, Bogotá	+5731052927	33
103	Valentina	Martínez Martínez	1996-03-24	F	Calle 80 #120-35, Santa Marta	+5731954227	29
104	Camila	Martínez Martínez	1966-12-10	F	Calle 222 #132-37, Cúcuta	+5737522515	58
105	Luis	Ramírez González	2009-04-27	M	Calle 50 #76-58, Sincelejo	+5734621616	16
106	Laura	Ramírez Gómez	1942-07-24	F	Calle 189 #52-85, Valledupar	+5730290468	83
107	William	Flórez Flórez	1979-09-13	M	Calle 258 #83-8, Neiva	+5731151825	46
108	Luis	Ruiz Gómez	1959-01-15	M	Calle 216 #71-3, Cúcuta	+5730873066	66
109	Claudia	Rodríguez Pérez	2003-01-01	F	Calle 281 #161-23, Ibagué	+5733715692	22
110	Sergio	Díaz Ruiz	2007-01-01	M	Calle 274 #61-72, Riohacha	+5737620014	18
111	Sandra	Flórez Castillo	1954-04-19	F	Calle 83 #156-14, Bucaramanga	+5739168852	71
112	Sergio	Mendoza Torres	1997-07-04	M	Calle 260 #36-21, Neiva	+5737598817	28
113	Ricardo	Ruiz Cruz	1935-08-19	M	Calle 189 #161-50, Cali	+5733615724	90
114	Juliana	González Castillo	1956-10-05	F	Calle 48 #24-14, Tunja	+5733425691	68
115	Ricardo	Rodríguez González	1933-06-06	M	Calle 48 #57-3, Cali	+5736059893	92
116	Natalia	Ramírez Suárez	1944-09-09	F	Calle 227 #99-49, Neiva	+5732516702	81
117	Sergio	Sánchez Rodríguez	1992-05-26	M	Calle 191 #181-82, Ibagué	+5734486123	33
118	Camilo	Ríos González	1984-03-25	M	Calle 277 #80-83, Tunja	+5739423203	41
119	Anderson	Torres Sánchez	2003-02-16	M	Calle 69 #39-60, Ibagué	+5732745837	22
120	Diego	Díaz Suárez	1986-02-07	M	Calle 59 #24-76, Sincelejo	+5739601200	39
121	Anderson	Pérez Castro	1941-06-13	M	Calle 285 #149-14, Barranquilla	+5738429727	84
122	Jairo	González Vargas	2003-08-13	M	Calle 136 #196-34, Tunja	+5738670501	22
123	Sergio	Rodríguez Díaz	2008-06-21	M	Calle 249 #190-50, Valledupar	+5738486877	17
124	Carolina	Castillo Flórez	2004-06-13	F	Calle 211 #49-46, Valledupar	+5733003001	21
125	Luis	Jiménez Díaz	1941-04-24	M	Calle 123 #129-83, Santa Marta	+5739448943	84
126	Jairo	Ramírez Ruiz	1944-04-21	M	Calle 290 #112-85, Santa Marta	+5730428073	81
127	Camilo	Rojas Vargas	1988-10-30	M	Calle 9 #47-6, Cúcuta	+5734781765	36
128	David	Martínez Díaz	1996-06-06	M	Calle 144 #164-16, Cúcuta	+5738576019	29
129	Laura	Ramírez Jiménez	1961-11-02	F	Calle 145 #22-15, Manizales	+5730937423	63
130	Andrea	Gómez Castro	1934-10-03	F	Calle 44 #71-73, Barranquilla	+5739548137	90
131	Edison	Cruz Gómez	1998-12-07	M	Calle 233 #44-5, Barranquilla	+5732220714	26
132	Juliana	Sánchez Martínez	1997-06-26	F	Calle 134 #105-47, Santa Marta	+5734385974	28
133	Mauricio	Castillo González	1993-05-05	M	Calle 198 #157-33, Cúcuta	+5739500174	32
134	Luis	Mendoza Ramírez	1996-07-03	M	Calle 160 #185-22, Cali	+5737425497	29
135	Andrés	Pérez Pérez	1960-10-24	M	Calle 185 #109-87, Cartagena	+5739251002	64
136	Juan	Flórez Díaz	1951-09-11	M	Calle 47 #73-84, Tunja	+5736808502	74
137	Andrés	Martínez Suárez	2007-12-04	M	Calle 20 #102-35, Cali	+5733362906	17
138	Paola	Pérez Jiménez	1952-07-19	F	Calle 121 #166-16, Cartagena	+5732958872	73
139	Carolina	Martínez Martínez	1974-08-19	F	Calle 16 #108-7, Tunja	+5730808461	51
140	Jorge	Gómez Mendoza	2003-11-11	M	Calle 71 #190-87, Manizales	+5736022040	21
141	Sergio	Mendoza Ríos	1996-07-28	M	Calle 191 #31-50, Cali	+5734656832	29
142	Mauricio	Martínez Castro	1991-10-08	M	Calle 259 #130-80, Neiva	+5737449979	33
143	Óscar	Torres Sánchez	1975-02-02	M	Calle 180 #15-48, Cali	+5730324679	50
144	María	Pérez Díaz	1978-05-04	F	Calle 250 #163-13, Valledupar	+5730960478	47
145	Edison	Jiménez Ruiz	1945-06-27	M	Calle 271 #139-21, Tunja	+5737452972	80
146	Diego	Martínez Díaz	2001-06-25	M	Calle 155 #153-18, Riohacha	+5736908720	24
147	Mauricio	Vargas Díaz	1973-09-30	M	Calle 96 #34-75, Sincelejo	+5730738873	51
148	Catalina	Mendoza Rojas	2004-10-06	F	Calle 14 #96-38, Barranquilla	+5739112851	20
149	Camilo	González Ramírez	1945-04-24	M	Calle 47 #11-21, Valledupar	+5737570465	80
150	María	Flórez Rodríguez	1933-02-21	F	Calle 220 #100-61, Riohacha	+5738836294	92
151	Claudia	Castro Sánchez	2006-11-04	F	Calle 192 #25-68, Medellín	+5738825060	18
152	Daniel	Díaz Castro	1933-12-20	M	Calle 155 #98-66, Cúcuta	+5730942110	91
153	Edison	Ramírez Suárez	1947-06-18	M	Calle 158 #150-15, Bogotá	+5735896237	78
154	Andrea	Ruiz Pérez	1972-03-24	F	Calle 198 #50-49, Bogotá	+5738224094	53
155	Jorge	Vargas Suárez	1962-06-15	M	Calle 293 #101-43, Ibagué	+5732389254	63
156	Luis	Flórez Torres	2008-06-15	M	Calle 173 #74-69, Bucaramanga	+5732142266	17
157	David	Vargas Jiménez	1962-07-19	M	Calle 99 #40-89, Cúcuta	+5734228792	63
158	Juliana	Jiménez Rojas	1932-01-28	F	Calle 129 #187-64, Cali	+5739234754	93
159	Valentina	Torres Rodríguez	2000-10-11	F	Calle 253 #162-52, Medellín	+5731698092	24
160	Alvaro	Sánchez Castro	1950-10-01	M	Calle 32 #68-81, Cartagena	+5739462959	74
161	William	Torres Pérez	1967-01-25	M	Calle 268 #177-41, Pereira	+5731496766	58
162	Natalia	Torres Vargas	2012-10-31	F	Calle 204 #63-59, Cúcuta	+5734822744	12
163	Carlos	Torres González	1966-03-11	M	Calle 271 #200-78, Cali	+5734869411	59
164	Luis	Cruz Díaz	1989-07-15	M	Calle 274 #98-60, Sincelejo	+5737402819	36
165	Carolina	Gómez Vargas	1935-12-27	F	Calle 253 #67-14, Ibagué	+5738603282	89
166	Marta	Jiménez Mendoza	1961-03-30	F	Calle 105 #150-75, Sincelejo	+5736405394	64
167	Alvaro	Cruz Vargas	1930-03-04	M	Calle 179 #70-23, Barranquilla	+5731886954	95
168	Juliana	Cruz Gómez	1978-01-22	F	Calle 264 #106-43, Medellín	+5733707669	47
169	Andrés	Sánchez Castillo	1930-07-29	M	Calle 260 #169-29, Bucaramanga	+5732110039	95
170	Natalia	Pérez Rodríguez	1993-12-11	F	Calle 284 #120-55, Barranquilla	+5739611283	31
171	Juliana	Torres Mendoza	1939-11-20	F	Calle 256 #60-22, Cúcuta	+5733395508	85
172	Lorena	Ríos Ruiz	1931-07-27	F	Calle 98 #52-89, Bucaramanga	+5731306969	94
173	Lucía	Torres Vargas	1932-12-24	F	Calle 230 #114-67, Bogotá	+5730500451	92
174	Carlos	Díaz Mendoza	1947-01-17	M	Calle 281 #133-47, Cúcuta	+5730111409	78
175	William	Rodríguez Rodríguez	1938-02-19	M	Calle 185 #3-80, Barranquilla	+5738489428	87
176	Natalia	Ríos Martínez	1930-09-07	F	Calle 295 #128-76, Manizales	+5733081609	95
177	Diego	Sánchez Vargas	1941-05-16	M	Calle 194 #68-56, Barranquilla	+5731849046	84
178	Paola	Cruz Pérez	1987-07-03	F	Calle 182 #12-28, Neiva	+5735579606	38
179	Paola	Mendoza Castillo	1956-10-02	F	Calle 261 #96-24, Manizales	+5730326647	68
180	Daniel	Jiménez Flórez	2015-07-23	M	Calle 235 #159-42, Cúcuta	+5733678449	10
181	Catalina	Sánchez Mendoza	1932-03-29	F	Calle 17 #8-24, Bogotá	+5738374721	93
182	Claudia	Gómez Ríos	1957-06-05	F	Calle 263 #102-8, Pereira	+5735932145	68
183	Laura	Ruiz Castillo	1937-01-24	F	Calle 39 #141-34, Ibagué	+5739581889	88
184	Ricardo	Gómez Flórez	2001-05-16	M	Calle 55 #38-70, Tunja	+5739471767	24
185	Laura	Rojas Mendoza	1989-05-29	F	Calle 275 #13-49, Medellín	+5731568350	36
186	Alvaro	Díaz González	1950-10-10	M	Calle 227 #57-21, Pereira	+5734162530	74
187	Valentina	Suárez Torres	1968-01-04	F	Calle 97 #114-7, Pereira	+5733496975	57
188	Paola	Sánchez Sánchez	1939-05-21	F	Calle 21 #12-56, Manizales	+5733719037	86
189	Jairo	Cruz Gómez	1952-08-30	M	Calle 34 #94-41, Barranquilla	+5731360628	73
190	Isabella	González Jiménez	1993-04-04	F	Calle 226 #158-24, Valledupar	+5734315954	32
191	Marta	Rojas Rodríguez	1954-10-02	F	Calle 138 #97-88, Neiva	+5732592731	70
192	Juan	Díaz González	1999-01-02	M	Calle 120 #83-35, Bogotá	+5738968222	26
193	Jairo	Sánchez Torres	1942-08-06	M	Calle 226 #18-90, Bogotá	+5734133907	83
194	Andrea	González Cruz	1980-03-07	F	Calle 135 #125-60, Barranquilla	+5731438950	45
195	Diana	Suárez Ramírez	1938-02-14	F	Calle 116 #138-57, Riohacha	+5737976140	87
196	Óscar	Ríos González	1975-09-01	M	Calle 192 #9-63, Pereira	+5732846052	50
197	Alvaro	Ríos Cruz	1972-02-06	M	Calle 35 #137-26, Riohacha	+5737282212	53
198	Sofía	Ramírez Cruz	1993-11-03	F	Calle 180 #166-54, Cúcuta	+5730693238	31
199	Paola	Sánchez Flórez	2018-02-13	F	Calle 139 #107-26, Sincelejo	+5739608055	7
200	Daniel	Cruz Flórez	2016-03-05	M	Calle 214 #94-22, Cúcuta	+5736491490	9
\.


--
-- Data for Name: patients_audit; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.patients_audit (audit_id, id, actionpatient, changed_at, changed_by, before_data, after_data) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, payment_date, amount, appointment_id) FROM stdin;
1	2025-05-13	114821.12	1
2	2023-10-31	284146.36	2
3	2024-03-10	229820.96	3
4	2023-05-25	132242.63	4
5	2023-01-18	230444.10	6
6	2024-12-17	250596.25	7
7	2024-07-18	132499.83	8
8	2021-12-27	107383.51	11
9	2023-09-18	119447.86	12
10	2021-03-18	205681.82	13
11	2025-08-22	121823.92	14
12	2023-08-27	212559.02	15
13	2022-11-08	229159.38	16
14	2024-08-07	226328.67	17
15	2025-02-21	134288.21	18
16	2021-04-08	207284.57	19
17	2024-01-09	185452.22	20
18	2021-02-19	92479.51	21
19	2023-02-15	110748.21	23
20	2024-02-02	262367.94	24
21	2024-11-16	199080.53	27
22	2021-10-03	142569.90	28
23	2024-05-11	142751.46	29
24	2023-11-08	238967.43	30
25	2023-10-03	209005.64	31
26	2023-05-16	68845.62	32
27	2021-07-13	277993.07	34
28	2025-01-19	234108.77	35
29	2022-12-05	132781.29	39
30	2023-12-08	280844.71	40
31	2024-11-19	153698.61	41
32	2022-03-31	212847.52	42
33	2022-04-30	169355.63	43
34	2021-03-31	262266.17	44
35	2022-05-26	139675.14	45
36	2022-06-04	177099.55	46
37	2025-05-05	206277.43	47
38	2024-05-26	145132.78	48
39	2025-01-05	133551.89	49
40	2021-02-05	79407.67	51
41	2024-01-29	247330.44	52
42	2023-03-26	125300.71	53
43	2022-01-20	98952.55	54
44	2024-01-01	69571.60	56
45	2021-05-05	196388.25	57
46	2023-03-13	94606.03	59
47	2021-07-19	157843.71	60
48	2023-10-01	236379.92	61
49	2024-01-10	210929.69	62
50	2021-11-10	140642.26	63
51	2022-07-07	195897.10	64
52	2025-03-26	83283.60	65
53	2022-07-13	128190.19	66
54	2023-02-02	176992.21	67
55	2023-01-31	113742.44	68
56	2024-05-02	219561.09	69
57	2025-05-29	79389.98	70
58	2021-04-13	169515.15	71
59	2021-11-29	206033.70	72
60	2023-03-26	95493.31	73
61	2022-03-14	116227.89	74
62	2023-10-18	92731.35	75
63	2022-10-06	268165.65	76
64	2021-10-26	117627.23	77
65	2023-03-01	111874.65	78
66	2021-06-14	160826.04	79
67	2021-10-01	225455.82	81
68	2022-08-20	255598.27	82
69	2022-04-27	156182.00	83
70	2023-05-07	269996.44	84
71	2024-02-29	244931.09	87
72	2021-07-16	270775.26	88
73	2022-06-04	259852.04	90
74	2024-02-09	211743.06	91
75	2023-11-30	94906.20	92
76	2023-06-16	255029.05	93
77	2024-11-05	206849.25	94
78	2023-02-04	121236.81	95
79	2024-02-03	258771.35	96
80	2021-11-29	140851.29	97
81	2024-08-30	169772.63	98
82	2022-01-19	110274.78	100
83	2025-01-01	131263.05	101
84	2023-11-27	179381.34	102
85	2023-06-21	169787.52	103
86	2022-07-11	264715.14	104
87	2025-01-27	251819.78	105
88	2024-04-07	151806.72	106
89	2022-05-12	156419.34	107
90	2021-09-14	127320.34	108
91	2025-06-01	294268.58	109
92	2021-07-10	215189.67	110
93	2022-01-08	225534.00	112
94	2022-07-31	74596.67	113
95	2023-01-14	69032.93	114
96	2023-03-08	287903.03	115
97	2023-10-22	213095.21	116
98	2022-10-05	256387.90	117
99	2022-11-22	202567.28	119
100	2021-06-22	235742.27	120
101	2025-01-02	110074.13	121
102	2023-11-09	94355.05	122
103	2023-09-02	262155.58	123
104	2021-08-23	161114.98	124
105	2021-07-23	189665.99	125
106	2025-04-01	68212.24	126
107	2023-01-03	79960.03	127
108	2023-05-10	135050.27	128
109	2023-04-12	173986.82	129
110	2022-09-19	183075.64	130
111	2024-09-17	232944.94	131
112	2023-05-02	209940.01	132
113	2025-02-04	272310.70	133
114	2023-07-02	145988.64	134
115	2022-01-26	285648.78	135
116	2022-09-21	79570.75	136
117	2023-10-24	139784.89	137
118	2023-05-21	184142.92	138
119	2022-06-04	64309.42	139
120	2021-03-10	272919.69	140
121	2024-07-12	134569.78	141
122	2024-12-31	125553.77	142
123	2025-08-10	189208.75	145
124	2024-11-26	273390.12	146
125	2021-10-05	119922.05	147
126	2022-12-22	287178.49	148
127	2021-04-18	85781.18	150
128	2022-05-30	133320.10	151
129	2022-11-22	60970.64	152
130	2025-09-08	83596.92	153
131	2023-01-14	239102.52	154
132	2022-05-28	90028.26	155
133	2024-05-23	145953.08	156
134	2023-06-07	165730.61	157
135	2022-11-19	69947.71	158
136	2022-04-28	294808.38	159
137	2022-03-07	127199.22	160
138	2021-03-04	109407.66	162
139	2023-03-02	173383.98	163
140	2021-03-23	215267.88	164
141	2025-06-04	299205.68	165
142	2022-07-27	250772.73	166
143	2024-10-05	103321.23	167
144	2023-11-08	221391.14	168
145	2023-09-07	167263.33	169
146	2022-10-04	213649.79	170
147	2021-01-07	245154.75	171
148	2023-10-29	288117.71	174
149	2021-04-10	79855.37	175
150	2022-02-27	216074.17	176
151	2025-04-14	204631.56	177
152	2022-05-01	126010.67	178
153	2025-03-05	212109.87	179
154	2021-10-16	242432.36	180
155	2021-02-19	245678.89	182
156	2021-09-26	251881.40	183
157	2024-04-16	163640.57	184
158	2025-06-26	179859.18	185
159	2021-10-12	283961.94	186
160	2021-12-19	87618.22	187
161	2022-11-16	118719.14	188
162	2023-11-20	148734.76	189
163	2023-10-21	106290.86	190
164	2024-02-10	61733.90	191
165	2023-09-27	138747.72	192
166	2022-05-13	299448.25	193
167	2024-08-08	75382.90	194
168	2022-05-26	90362.57	195
169	2023-03-04	116835.38	196
170	2022-02-16	91107.44	197
171	2022-02-06	104923.18	198
172	2025-06-14	235085.88	200
173	2021-10-26	169333.62	201
174	2023-03-31	196422.11	202
175	2021-06-21	142788.28	203
176	2022-02-13	227834.46	204
177	2023-07-03	226071.71	205
178	2022-07-03	206275.26	206
179	2024-01-07	234631.61	207
180	2021-05-23	193725.17	208
181	2024-04-17	149805.65	209
182	2024-09-03	67496.82	210
183	2022-03-19	88820.53	211
184	2024-02-12	179783.11	212
185	2023-06-03	277529.86	213
186	2025-02-08	259270.27	214
187	2023-07-22	242177.89	215
188	2025-01-06	189523.95	216
189	2023-02-07	260208.94	217
190	2022-05-24	200682.14	218
191	2025-07-11	240462.65	220
192	2023-09-03	121101.20	221
193	2024-12-16	138157.55	222
194	2022-11-19	290730.15	223
195	2021-07-29	83990.02	225
196	2024-05-12	144477.02	226
197	2022-01-23	63139.53	227
198	2024-09-05	242000.36	229
199	2021-06-03	277013.28	230
200	2024-02-21	234402.98	231
201	2025-01-09	84333.74	232
202	2024-07-09	104821.84	233
203	2023-06-18	241326.32	234
204	2024-08-23	221351.16	235
205	2024-12-26	141407.12	236
206	2025-09-11	90912.81	237
207	2025-03-27	100986.67	238
208	2022-11-28	120197.96	239
209	2023-05-22	248764.46	240
210	2022-11-29	225171.37	241
211	2022-06-02	74548.00	242
212	2023-06-18	140587.87	243
213	2023-04-26	158802.52	244
214	2021-08-01	60009.99	245
215	2021-05-14	287690.70	246
216	2022-12-07	256566.93	247
217	2023-04-03	208496.38	248
218	2024-12-22	260262.45	249
219	2021-04-07	199333.35	250
220	2023-03-09	136885.57	251
221	2025-02-22	139347.40	252
222	2023-05-26	186314.74	253
223	2021-07-01	116960.74	254
224	2023-03-08	121637.86	255
225	2025-07-25	146904.72	256
226	2021-07-09	170554.64	257
227	2024-06-06	121311.26	258
228	2023-02-26	196956.52	259
229	2022-09-02	65150.10	260
230	2024-09-11	124627.32	262
231	2021-06-24	137328.16	263
232	2023-07-21	277970.64	264
233	2022-02-07	106296.98	265
234	2025-09-25	241478.78	266
235	2021-05-28	118167.75	267
236	2025-06-25	81633.74	269
237	2022-08-07	219029.16	270
238	2023-11-26	269588.55	271
239	2025-08-15	62852.97	274
240	2021-12-04	153294.89	275
241	2021-07-18	160017.74	277
242	2025-09-06	230609.06	279
243	2022-07-27	124660.29	282
244	2023-11-16	172765.42	283
245	2023-06-25	191023.37	285
246	2024-09-24	206966.95	286
247	2021-06-20	113820.77	287
248	2021-05-20	216881.28	288
249	2024-05-09	117879.96	289
250	2021-02-22	238017.75	290
251	2024-11-24	253566.88	291
252	2024-12-04	87509.95	292
253	2021-07-20	194306.55	293
254	2024-11-08	278840.53	294
255	2022-12-19	125890.67	295
256	2022-12-15	137323.43	296
257	2021-11-20	165510.23	297
258	2024-05-22	246655.79	298
259	2024-02-04	261305.95	299
260	2023-03-01	225058.15	300
261	2021-05-25	291505.24	301
262	2021-11-28	192806.27	302
263	2025-03-08	280454.83	303
264	2022-09-04	152111.72	306
265	2021-05-25	181275.08	307
266	2021-10-19	246586.69	308
267	2023-08-23	289964.62	309
268	2022-11-29	135520.85	310
269	2023-04-13	131251.53	312
270	2021-04-08	134793.25	313
271	2024-09-20	259562.66	314
272	2024-10-18	229523.57	316
273	2025-03-08	255707.92	317
274	2024-07-24	279014.68	318
275	2022-05-27	237915.64	319
276	2022-11-25	170194.40	320
277	2022-02-05	166262.19	321
278	2021-10-12	230563.00	322
279	2022-10-20	92017.66	323
280	2023-02-14	197958.89	324
281	2023-11-10	87553.36	325
282	2022-07-12	220596.85	327
283	2024-07-14	283732.81	328
284	2025-05-16	88198.38	329
285	2023-07-29	102188.93	330
286	2023-05-08	222849.56	331
287	2022-09-30	253647.71	333
288	2021-12-31	210814.87	334
289	2022-02-17	210522.06	335
290	2024-02-28	102041.02	336
291	2025-09-29	103423.25	337
292	2023-02-17	141488.43	339
293	2021-02-28	228780.26	340
294	2023-01-24	244011.82	341
295	2022-05-04	150999.04	342
296	2022-12-09	194075.90	343
297	2022-11-20	201038.30	344
298	2025-02-24	204787.96	345
299	2022-03-23	124135.05	346
300	2023-04-06	169779.55	347
301	2023-05-24	163051.75	349
302	2023-12-16	189331.96	350
\.


--
-- Data for Name: payments_audit; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments_audit (audit_id, id, actionpayment, changed_at, changed_by, before_data, after_data) FROM stdin;
\.


--
-- Data for Name: prescriptions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.prescriptions (id, prescription_date, appointment_id) FROM stdin;
1	2024-08-24	27
2	2022-07-12	320
3	2024-03-08	313
4	2021-11-01	257
5	2024-08-07	177
6	2021-02-09	180
7	2022-07-30	293
8	2023-05-10	205
9	2022-10-26	347
10	2024-07-13	290
11	2025-01-06	67
12	2024-12-06	105
13	2022-05-25	257
14	2021-02-16	304
15	2022-02-14	207
16	2022-04-10	310
17	2024-05-07	211
18	2023-01-30	278
19	2021-05-22	94
20	2025-05-17	112
21	2021-10-13	232
22	2021-08-21	30
23	2023-02-28	175
24	2022-06-05	341
25	2023-04-27	129
26	2023-08-22	167
27	2024-08-05	40
28	2024-04-14	185
29	2025-04-12	267
30	2023-10-30	56
31	2022-02-13	77
32	2022-01-22	343
33	2023-06-07	54
34	2022-10-05	199
35	2021-07-24	228
36	2022-11-09	129
37	2023-08-30	218
38	2023-07-22	222
39	2023-04-02	50
40	2021-06-25	157
41	2022-10-03	39
42	2024-05-22	315
43	2022-12-24	103
44	2024-07-20	307
45	2023-02-25	288
46	2024-07-14	46
47	2022-07-27	318
48	2021-05-30	294
49	2024-12-18	76
50	2023-05-10	52
51	2023-09-17	140
52	2023-07-02	66
53	2021-07-25	311
54	2025-04-12	130
55	2021-04-25	218
56	2025-05-04	147
57	2024-12-16	53
58	2021-01-25	227
59	2025-03-28	168
60	2023-09-16	226
61	2024-07-13	208
62	2023-05-21	66
63	2021-12-25	205
64	2023-05-27	73
65	2022-06-04	130
66	2023-02-28	254
67	2023-05-01	317
68	2023-01-05	155
69	2025-09-26	27
70	2023-01-20	330
71	2025-09-25	90
72	2022-10-02	348
73	2024-07-14	73
74	2022-02-03	235
75	2025-06-05	224
76	2024-06-08	86
77	2023-01-16	165
78	2021-05-22	116
79	2022-07-13	48
80	2023-01-16	165
81	2024-09-22	109
82	2021-09-13	265
83	2024-11-06	265
84	2022-02-03	177
85	2022-10-26	224
86	2023-06-30	87
87	2022-01-22	253
88	2021-10-26	339
89	2025-01-02	10
90	2023-07-16	240
91	2025-01-17	288
92	2022-12-12	284
93	2025-01-06	109
94	2023-05-17	5
95	2024-04-07	110
96	2021-03-03	33
97	2022-12-24	107
98	2021-03-15	135
99	2021-07-31	138
100	2023-09-17	239
101	2024-09-01	112
102	2025-06-27	323
103	2021-04-05	183
104	2022-10-20	84
105	2021-05-31	203
106	2023-11-09	348
107	2021-07-20	82
108	2021-05-11	234
109	2022-05-09	295
110	2022-03-14	242
111	2024-09-22	260
112	2021-10-23	79
113	2023-05-01	290
114	2023-05-27	172
115	2023-06-18	87
116	2022-06-30	29
117	2023-11-27	115
118	2024-02-26	265
119	2023-11-07	264
120	2022-11-27	46
121	2023-03-01	266
122	2023-05-22	255
123	2025-03-03	278
124	2025-09-25	343
125	2022-05-02	109
126	2021-03-15	57
127	2023-07-01	138
128	2025-09-25	96
129	2024-05-07	76
130	2022-12-24	317
131	2024-11-26	77
132	2022-03-21	257
133	2023-08-29	59
134	2021-07-07	50
135	2023-05-08	257
136	2022-07-09	54
137	2023-04-02	115
138	2023-04-02	176
139	2023-03-03	210
140	2023-11-27	40
141	2025-07-31	187
142	2021-11-12	193
143	2023-07-16	275
144	2022-11-27	94
145	2025-07-10	156
146	2022-06-30	104
147	2021-06-28	235
148	2023-03-01	180
149	2021-10-18	336
150	2022-02-03	52
151	2022-11-18	335
152	2022-02-28	5
153	2025-07-31	120
154	2022-11-19	139
155	2025-07-27	93
156	2024-04-29	260
157	2023-10-22	246
158	2023-06-03	17
159	2024-01-09	187
160	2022-01-22	120
161	2025-08-20	107
162	2021-05-22	32
163	2021-05-02	67
164	2021-11-30	49
165	2021-10-14	199
166	2021-04-05	181
167	2025-02-20	165
168	2025-05-17	308
169	2022-04-28	43
170	2023-03-26	113
171	2025-02-07	136
172	2022-05-26	315
173	2021-11-26	235
174	2022-12-09	345
175	2022-11-22	124
176	2024-01-09	60
177	2025-01-02	275
178	2021-10-16	258
179	2023-01-20	181
180	2023-05-21	249
181	2023-05-14	341
182	2022-04-10	317
183	2024-09-01	304
184	2023-08-29	36
185	2024-09-22	154
186	2023-06-30	122
187	2021-04-10	47
188	2024-11-22	122
189	2021-03-15	188
190	2021-06-28	285
191	2025-07-10	260
192	2021-10-23	10
193	2022-01-25	286
194	2023-11-09	265
195	2024-09-22	181
196	2025-03-03	189
197	2023-09-16	175
198	2024-02-04	8
199	2022-12-24	277
200	2021-04-10	205
\.


--
-- Data for Name: procedures; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.procedures (id, description, appointment_id) FROM stdin;
1	Colocación de inyectable	263
2	Rayos X simple	115
3	Curación de herida	145
4	Vendaje	325
5	Extracción dental	304
6	Vendaje	319
7	Vendaje	51
8	Fisioterapia inicial	176
9	Vendaje	70
10	Colocación de inyectable	270
11	ECG	27
12	Colocación de yeso	268
13	Vendaje	3
14	Rayos X simple	77
15	Fisioterapia inicial	255
16	ECG	96
17	Toma de muestra	100
18	Limpieza dental	285
19	Colocación de inyectable	232
20	Colocación de inyectable	14
21	Rayos X simple	124
22	ECG	269
23	Extracción dental	29
24	ECG	173
25	Sutura	206
26	Limpieza dental	230
27	Fisioterapia inicial	34
28	Educación en higiene	52
29	Colocación de inyectable	193
30	Curación de herida	113
31	Curación de herida	20
32	Sutura	258
33	Colocación de yeso	269
34	Curación de herida	273
35	Colocación de inyectable	73
36	Limpieza dental	158
37	Curación de herida	58
38	Colocación de yeso	338
39	Colocación de inyectable	321
40	Sutura	120
41	Sutura	268
42	Vendaje	125
43	Rayos X simple	85
44	Curación de herida	66
45	Colocación de yeso	18
46	Colocación de inyectable	307
47	Fisioterapia inicial	237
48	Limpieza dental	314
49	Sutura	231
50	Fisioterapia inicial	341
51	Curación de herida	16
52	Rayos X simple	331
53	Sutura	254
54	Fisioterapia inicial	164
55	Curación de herida	141
56	Extracción dental	188
57	Toma de muestra	100
58	Educación en higiene	194
59	Colocación de inyectable	311
60	Limpieza dental	330
61	Curación de herida	198
62	Fisioterapia inicial	125
63	Limpieza dental	17
64	Limpieza dental	289
65	Colocación de yeso	341
66	Fisioterapia inicial	202
67	Colocación de yeso	16
68	Colocación de inyectable	203
69	Extracción dental	261
70	Colocación de inyectable	343
71	Colocación de yeso	232
72	Curación de herida	127
73	Rayos X simple	11
74	Curación de herida	28
75	Curación de herida	212
76	Sutura	324
77	Rayos X simple	75
78	Colocación de inyectable	293
79	Colocación de yeso	339
80	Colocación de yeso	152
81	Extracción dental	285
82	Fisioterapia inicial	350
83	Limpieza dental	55
84	Educación en higiene	51
85	Extracción dental	59
86	Fisioterapia inicial	238
87	Toma de muestra	225
88	ECG	83
89	Colocación de inyectable	184
90	Educación en higiene	273
91	Educación en higiene	103
92	Vendaje	11
93	Rayos X simple	261
94	ECG	36
95	Curación de herida	290
96	Limpieza dental	213
97	Vendaje	31
98	ECG	150
99	Educación en higiene	38
100	Rayos X simple	51
101	Colocación de yeso	341
102	Limpieza dental	124
103	Extracción dental	249
104	Educación en higiene	83
105	ECG	243
106	Limpieza dental	120
107	ECG	32
108	Curación de herida	78
109	Toma de muestra	61
110	Vendaje	135
111	Toma de muestra	66
112	Fisioterapia inicial	264
113	Fisioterapia inicial	329
114	Rayos X simple	213
115	Curación de herida	46
116	ECG	296
117	Vendaje	105
118	Educación en higiene	126
119	ECG	319
120	Colocación de yeso	102
121	Fisioterapia inicial	205
122	Curación de herida	225
123	Sutura	188
124	Extracción dental	195
125	Limpieza dental	4
126	Limpieza dental	74
127	Extracción dental	109
128	Extracción dental	92
129	Toma de muestra	136
130	Rayos X simple	118
131	Sutura	76
132	Colocación de yeso	308
133	Curación de herida	136
134	Colocación de yeso	338
135	Colocación de inyectable	121
136	Curación de herida	198
137	ECG	193
138	ECG	22
139	Fisioterapia inicial	185
140	Educación en higiene	343
141	Sutura	203
142	ECG	303
143	Limpieza dental	19
144	Colocación de yeso	146
145	Toma de muestra	238
146	Extracción dental	83
147	Rayos X simple	129
148	Educación en higiene	307
149	Extracción dental	308
150	Sutura	199
\.


--
-- Data for Name: recipe_details; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recipe_details (id, amount, indications, prescription_id, medicine_id) FROM stdin;
1	6	Usar según indicación médica	1	76
2	1	Tomar después de alimentos	2	36
3	10	Aplicar tópico 2 veces al día	2	115
4	7	Una vez al día	2	6
5	17	Aplicar tópico 2 veces al día	3	115
6	1	No conducir tras la dosis	3	77
7	10	Tomar antes de alimentos	4	149
8	11	Tomar después de alimentos	4	57
9	4	Usar según indicación médica	4	15
10	18	Tomar antes de alimentos	5	77
11	15	Cada 8 horas	6	83
12	19	Aplicar tópico 2 veces al día	7	4
13	1	Tomar después de alimentos	8	140
14	11	Cada 8 horas	8	54
15	11	Aplicar tópico 2 veces al día	9	149
16	8	Cada 8 horas	10	80
17	15	Aplicar tópico 2 veces al día	10	14
18	9	No conducir tras la dosis	10	128
19	5	Tomar después de alimentos	11	124
20	7	Tomar después de alimentos	12	88
21	17	Tomar antes de alimentos	12	42
22	3	Aplicar tópico 2 veces al día	13	116
23	19	Cada 8 horas	13	41
24	19	Tomar después de alimentos	13	17
25	2	No conducir tras la dosis	14	92
26	7	No conducir tras la dosis	15	124
27	14	Usar según indicación médica	15	48
28	10	Una vez al día	15	27
29	1	No conducir tras la dosis	16	13
30	8	Tomar después de alimentos	17	132
31	5	No conducir tras la dosis	18	76
32	18	Tomar después de alimentos	19	55
33	5	Cada 8 horas	19	32
34	15	No conducir tras la dosis	20	59
35	3	Cada 8 horas	20	17
36	17	Aplicar tópico 2 veces al día	20	31
37	14	Tomar antes de alimentos	21	143
38	19	Una vez al día	22	126
39	9	Tomar antes de alimentos	22	104
40	20	No conducir tras la dosis	22	62
41	10	Una vez al día	23	108
42	18	Cada 8 horas	23	77
43	18	No conducir tras la dosis	24	47
44	7	Una vez al día	24	19
45	6	Cada 8 horas	25	81
46	13	Aplicar tópico 2 veces al día	25	94
47	11	Cada 8 horas	26	66
48	19	Usar según indicación médica	26	43
49	11	Aplicar tópico 2 veces al día	26	63
50	6	No conducir tras la dosis	27	96
51	2	Tomar antes de alimentos	27	61
52	20	Tomar antes de alimentos	27	112
53	7	Usar según indicación médica	28	4
54	9	Una vez al día	29	39
55	20	Tomar antes de alimentos	30	123
56	9	Tomar después de alimentos	30	146
57	19	Usar según indicación médica	30	28
58	6	No conducir tras la dosis	31	34
59	18	No conducir tras la dosis	31	63
60	4	No conducir tras la dosis	31	146
61	13	Una vez al día	32	21
62	4	No conducir tras la dosis	32	89
63	2	Usar según indicación médica	32	147
64	8	No conducir tras la dosis	33	54
65	7	Una vez al día	33	131
66	1	Tomar después de alimentos	33	105
67	6	No conducir tras la dosis	34	143
68	12	Tomar después de alimentos	34	128
69	7	Cada 8 horas	34	94
70	16	Tomar antes de alimentos	35	126
71	1	Tomar después de alimentos	35	107
72	7	Una vez al día	36	85
73	8	Usar según indicación médica	37	30
74	13	Aplicar tópico 2 veces al día	37	59
75	15	Aplicar tópico 2 veces al día	38	2
76	16	Aplicar tópico 2 veces al día	38	55
77	9	Usar según indicación médica	38	123
78	15	Cada 8 horas	39	30
79	20	Una vez al día	39	4
80	10	Usar según indicación médica	39	18
81	13	Tomar antes de alimentos	40	67
82	14	No conducir tras la dosis	40	16
83	16	No conducir tras la dosis	40	96
84	1	No conducir tras la dosis	41	24
85	16	Una vez al día	41	114
86	18	Usar según indicación médica	42	22
87	8	Tomar antes de alimentos	43	102
88	12	Tomar antes de alimentos	43	35
89	14	Tomar antes de alimentos	44	49
90	15	Una vez al día	45	74
91	4	No conducir tras la dosis	45	41
92	2	Aplicar tópico 2 veces al día	45	96
93	10	No conducir tras la dosis	46	23
94	7	Cada 8 horas	46	14
95	19	Usar según indicación médica	47	110
96	3	Tomar antes de alimentos	47	93
97	18	Tomar después de alimentos	48	10
98	19	Tomar después de alimentos	48	68
99	16	Tomar después de alimentos	49	104
100	18	Tomar después de alimentos	50	122
101	18	No conducir tras la dosis	50	140
102	18	Aplicar tópico 2 veces al día	50	145
103	19	Una vez al día	51	75
104	1	Aplicar tópico 2 veces al día	52	63
105	7	Tomar después de alimentos	53	47
106	3	Cada 8 horas	54	47
107	5	Tomar después de alimentos	55	32
108	16	Tomar después de alimentos	55	88
109	4	Una vez al día	55	63
110	5	Una vez al día	56	79
111	4	No conducir tras la dosis	56	33
112	15	Tomar antes de alimentos	56	124
113	2	Usar según indicación médica	57	26
114	12	No conducir tras la dosis	57	116
115	20	Aplicar tópico 2 veces al día	58	96
116	2	Tomar antes de alimentos	58	130
117	19	Aplicar tópico 2 veces al día	58	23
118	9	Tomar después de alimentos	59	134
119	1	No conducir tras la dosis	60	87
120	4	Aplicar tópico 2 veces al día	60	4
121	14	No conducir tras la dosis	61	97
122	18	No conducir tras la dosis	61	129
123	8	No conducir tras la dosis	62	2
124	14	Una vez al día	62	51
125	12	Aplicar tópico 2 veces al día	62	31
126	19	No conducir tras la dosis	63	147
127	5	Tomar después de alimentos	63	56
128	10	Tomar después de alimentos	63	37
129	7	Aplicar tópico 2 veces al día	64	11
130	6	Aplicar tópico 2 veces al día	64	43
131	1	Tomar después de alimentos	64	101
132	17	Cada 8 horas	65	11
133	18	No conducir tras la dosis	66	68
134	4	Usar según indicación médica	67	115
135	2	Cada 8 horas	67	22
136	11	Tomar antes de alimentos	68	85
137	8	Usar según indicación médica	68	82
138	5	Aplicar tópico 2 veces al día	69	101
139	7	Usar según indicación médica	69	9
140	14	Cada 8 horas	69	86
141	4	Tomar antes de alimentos	70	94
142	18	Tomar después de alimentos	70	22
143	20	Tomar antes de alimentos	70	95
144	16	Cada 8 horas	71	10
145	13	Tomar después de alimentos	71	137
146	10	No conducir tras la dosis	71	122
147	19	Una vez al día	72	84
148	5	Aplicar tópico 2 veces al día	72	51
149	7	Tomar después de alimentos	72	82
150	1	Una vez al día	73	93
151	11	No conducir tras la dosis	74	99
152	7	Usar según indicación médica	75	102
153	6	Aplicar tópico 2 veces al día	76	36
154	4	Una vez al día	76	98
155	11	Tomar antes de alimentos	76	34
156	15	Aplicar tópico 2 veces al día	77	135
157	4	Usar según indicación médica	78	51
158	14	Usar según indicación médica	78	2
159	3	Una vez al día	78	113
160	18	Aplicar tópico 2 veces al día	79	98
161	15	Tomar antes de alimentos	79	36
162	17	Tomar después de alimentos	79	87
163	6	No conducir tras la dosis	80	78
164	16	Una vez al día	80	135
165	6	Tomar después de alimentos	80	146
166	17	Aplicar tópico 2 veces al día	81	43
167	17	Tomar después de alimentos	82	109
168	13	Tomar antes de alimentos	83	110
169	8	Usar según indicación médica	83	35
170	19	Cada 8 horas	84	86
171	2	Usar según indicación médica	85	39
172	12	Tomar antes de alimentos	85	93
173	9	Usar según indicación médica	86	93
174	2	Usar según indicación médica	86	111
175	7	Tomar después de alimentos	87	135
176	6	Cada 8 horas	87	74
177	9	Una vez al día	88	115
178	20	Tomar después de alimentos	88	95
179	3	Una vez al día	89	4
180	5	Usar según indicación médica	89	141
181	11	Usar según indicación médica	89	126
182	7	No conducir tras la dosis	90	30
183	20	Tomar antes de alimentos	90	91
184	19	Usar según indicación médica	91	41
185	19	Una vez al día	92	3
186	6	Una vez al día	92	112
187	19	Tomar después de alimentos	93	30
188	14	Cada 8 horas	93	92
189	10	Cada 8 horas	93	130
190	16	Aplicar tópico 2 veces al día	94	102
191	16	Tomar antes de alimentos	94	39
192	20	Una vez al día	94	19
193	14	Tomar antes de alimentos	95	122
194	9	Tomar después de alimentos	95	38
195	5	Tomar después de alimentos	95	9
196	5	Una vez al día	96	4
197	3	Aplicar tópico 2 veces al día	96	143
198	19	Aplicar tópico 2 veces al día	96	17
199	2	No conducir tras la dosis	97	123
200	1	Tomar después de alimentos	98	100
201	18	Cada 8 horas	99	31
202	16	Tomar después de alimentos	100	26
203	5	Usar según indicación médica	100	107
204	3	Tomar antes de alimentos	100	139
205	16	Una vez al día	101	120
206	16	Aplicar tópico 2 veces al día	101	30
207	12	No conducir tras la dosis	102	124
208	15	Tomar antes de alimentos	103	104
209	13	Usar según indicación médica	103	83
210	2	Usar según indicación médica	104	59
211	2	Usar según indicación médica	104	97
212	18	Una vez al día	105	109
213	5	Aplicar tópico 2 veces al día	105	17
214	13	Tomar antes de alimentos	106	67
215	14	Una vez al día	107	117
216	7	Cada 8 horas	107	47
217	20	Usar según indicación médica	107	112
218	9	Aplicar tópico 2 veces al día	108	139
219	16	No conducir tras la dosis	108	5
220	1	Cada 8 horas	108	87
221	4	Aplicar tópico 2 veces al día	109	106
222	7	Tomar después de alimentos	109	82
223	14	Una vez al día	109	50
224	6	Usar según indicación médica	110	123
225	6	Una vez al día	110	105
226	9	Tomar después de alimentos	110	54
227	12	Usar según indicación médica	111	35
228	15	Tomar después de alimentos	111	120
229	2	Cada 8 horas	112	109
230	6	Aplicar tópico 2 veces al día	113	18
231	8	No conducir tras la dosis	114	88
232	19	Usar según indicación médica	115	89
233	2	No conducir tras la dosis	115	129
234	7	Tomar antes de alimentos	115	61
235	4	Tomar antes de alimentos	116	37
236	12	Cada 8 horas	116	100
237	14	No conducir tras la dosis	116	140
238	6	Una vez al día	117	13
239	5	Tomar después de alimentos	117	58
240	12	Tomar antes de alimentos	117	14
241	3	Tomar después de alimentos	118	79
242	8	Aplicar tópico 2 veces al día	119	142
243	18	No conducir tras la dosis	119	83
244	12	Aplicar tópico 2 veces al día	119	90
245	9	Tomar después de alimentos	120	7
246	6	Tomar antes de alimentos	120	145
247	13	No conducir tras la dosis	120	69
248	4	Tomar antes de alimentos	121	149
249	19	Una vez al día	121	20
250	8	Cada 8 horas	121	98
251	1	Una vez al día	122	109
252	13	No conducir tras la dosis	122	132
253	10	Tomar después de alimentos	123	33
254	4	Cada 8 horas	123	43
255	8	Usar según indicación médica	124	8
256	6	Tomar después de alimentos	124	125
257	4	Tomar antes de alimentos	124	2
258	3	Tomar antes de alimentos	125	73
259	10	Tomar antes de alimentos	125	115
260	13	Aplicar tópico 2 veces al día	126	91
261	3	Aplicar tópico 2 veces al día	126	40
262	8	Usar según indicación médica	126	58
263	3	No conducir tras la dosis	127	19
264	8	Aplicar tópico 2 veces al día	127	10
265	11	Tomar antes de alimentos	127	99
266	5	Tomar después de alimentos	128	59
267	6	Una vez al día	129	82
268	10	No conducir tras la dosis	129	11
269	20	Tomar antes de alimentos	130	2
270	8	Aplicar tópico 2 veces al día	130	17
271	15	Aplicar tópico 2 veces al día	130	84
272	7	Tomar antes de alimentos	131	132
273	10	Tomar después de alimentos	131	119
274	19	Tomar antes de alimentos	132	107
275	7	Usar según indicación médica	133	92
276	5	Tomar después de alimentos	134	131
277	3	No conducir tras la dosis	134	144
278	1	Tomar antes de alimentos	135	121
279	9	Tomar después de alimentos	136	57
280	7	Una vez al día	136	6
281	14	Una vez al día	137	137
282	10	Una vez al día	137	91
283	15	Cada 8 horas	137	75
284	15	Aplicar tópico 2 veces al día	138	135
285	14	Una vez al día	138	11
286	10	Tomar antes de alimentos	138	149
287	8	No conducir tras la dosis	139	122
288	1	No conducir tras la dosis	140	141
289	11	Una vez al día	141	39
290	16	Tomar antes de alimentos	141	109
291	1	Usar según indicación médica	142	69
292	17	Aplicar tópico 2 veces al día	142	122
293	19	Cada 8 horas	143	46
294	18	Cada 8 horas	144	99
295	13	Tomar después de alimentos	145	100
296	4	Usar según indicación médica	146	28
297	8	Usar según indicación médica	146	96
298	3	Tomar antes de alimentos	147	135
299	7	Cada 8 horas	148	87
300	2	Tomar después de alimentos	148	141
301	6	Usar según indicación médica	148	74
302	2	Usar según indicación médica	149	120
303	11	Cada 8 horas	149	22
304	4	No conducir tras la dosis	150	108
305	11	Una vez al día	150	58
306	6	Usar según indicación médica	150	75
307	13	Usar según indicación médica	151	13
308	12	Tomar después de alimentos	151	94
309	13	Tomar antes de alimentos	151	93
310	1	Tomar antes de alimentos	152	6
311	19	Cada 8 horas	152	40
312	20	Una vez al día	153	142
313	15	No conducir tras la dosis	154	28
314	19	No conducir tras la dosis	155	103
315	14	Aplicar tópico 2 veces al día	156	130
316	15	Una vez al día	157	113
317	20	Aplicar tópico 2 veces al día	158	17
318	6	Tomar antes de alimentos	158	79
319	6	Cada 8 horas	159	51
320	9	No conducir tras la dosis	159	133
321	20	Una vez al día	159	32
322	18	Usar según indicación médica	160	1
323	3	Usar según indicación médica	160	117
324	15	Tomar después de alimentos	161	51
325	2	Una vez al día	161	37
326	16	No conducir tras la dosis	161	137
327	16	Cada 8 horas	162	9
328	8	Una vez al día	163	15
329	7	Usar según indicación médica	164	17
330	10	Aplicar tópico 2 veces al día	164	99
331	16	Aplicar tópico 2 veces al día	165	141
332	2	Tomar antes de alimentos	165	7
333	18	Usar según indicación médica	166	120
334	4	Usar según indicación médica	167	12
335	3	Tomar antes de alimentos	168	119
336	10	Cada 8 horas	169	130
337	14	Una vez al día	169	50
338	4	Cada 8 horas	170	19
339	12	Aplicar tópico 2 veces al día	170	49
340	8	Tomar después de alimentos	171	138
341	1	Aplicar tópico 2 veces al día	172	56
342	12	Cada 8 horas	173	105
343	12	Usar según indicación médica	174	127
344	1	Una vez al día	174	25
345	10	Una vez al día	174	102
346	19	Una vez al día	175	62
347	18	Una vez al día	175	147
348	10	Cada 8 horas	176	74
349	20	Una vez al día	177	37
350	17	Tomar después de alimentos	177	39
351	12	No conducir tras la dosis	177	106
352	5	No conducir tras la dosis	178	20
353	4	Tomar antes de alimentos	178	141
354	16	Tomar antes de alimentos	179	12
355	3	Aplicar tópico 2 veces al día	179	40
356	15	No conducir tras la dosis	179	150
357	18	Tomar antes de alimentos	180	31
358	8	Aplicar tópico 2 veces al día	181	136
359	8	Cada 8 horas	181	35
360	11	Usar según indicación médica	182	23
361	17	Tomar antes de alimentos	182	58
362	20	Tomar después de alimentos	183	85
363	11	Una vez al día	184	118
364	2	No conducir tras la dosis	184	135
365	1	Una vez al día	184	36
366	4	No conducir tras la dosis	185	2
367	18	Tomar después de alimentos	186	120
368	6	Tomar después de alimentos	187	104
369	20	Aplicar tópico 2 veces al día	188	49
370	14	Tomar antes de alimentos	188	93
371	12	Tomar después de alimentos	189	144
372	9	Tomar antes de alimentos	190	8
373	17	Tomar después de alimentos	190	5
374	13	Cada 8 horas	190	118
375	14	Tomar antes de alimentos	191	127
376	2	Aplicar tópico 2 veces al día	191	52
377	17	No conducir tras la dosis	192	62
378	18	Usar según indicación médica	193	43
379	17	Una vez al día	193	32
380	3	No conducir tras la dosis	193	71
381	17	Cada 8 horas	194	7
382	7	Cada 8 horas	194	49
383	13	Cada 8 horas	195	121
384	4	Tomar después de alimentos	195	88
385	2	No conducir tras la dosis	196	107
386	15	Tomar antes de alimentos	196	133
387	8	Cada 8 horas	196	89
388	7	Tomar antes de alimentos	197	140
389	17	Aplicar tópico 2 veces al día	197	10
390	16	Cada 8 horas	198	126
391	2	Una vez al día	198	5
392	15	Tomar antes de alimentos	198	119
393	8	Tomar después de alimentos	199	113
394	15	Aplicar tópico 2 veces al día	200	101
395	11	Cada 8 horas	200	2
\.


--
-- Data for Name: recipe_details_audit; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recipe_details_audit (audit_id, id, actionrecipe, changed_at, changed_by, before_data, after_data) FROM stdin;
\.


--
-- Data for Name: specialties; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.specialties (id, name_specialty) FROM stdin;
1	Medicina General
2	Pediatría
3	Ginecología
4	Cardiología
5	Dermatología
6	Odontología
7	Neurología
8	Oftalmología
9	Otorrinolaringología
10	Psiquiatría
11	Endocrinología
12	Gastroenterología
13	Nefrología
14	Urología
15	Reumatología
16	Traumatología y Ortopedia
17	Neumología
18	Infectología
19	Oncología
20	Medicina Interna
21	Cardiología - Sede 1
22	Dermatología - Sede 2
23	Neurología - Sede 3
24	Oftalmología - Sede 4
25	Endocrinología - Sede 5
26	Geriatría - Sede 6
27	Medicina del Deporte - Sede 7
28	Rehabilitación - Sede 8
29	Cirugía General - Sede 1
30	Cirugía Plástica - Sede 2
31	Anestesiología - Sede 3
32	Radiología - Sede 4
33	Hematología - Sede 5
34	Inmunología - Sede 6
35	Medicina Familiar - Sede 7
36	Odontopediatría - Sede 8
37	Ginecología y Obstetricia - Sede 1
38	Urología - Sede 2
39	Pediatría Neonatal - Sede 3
40	Medicina Laboral - Sede 4
41	Urgencias - Sede 5
42	Medicina Crítica - Sede 6
43	Nutrición - Sede 7
44	Psicología Clínica - Sede 8
45	Fisioterapia - Sede 1
46	Terapia Ocupacional - Sede 2
47	Logopedia - Sede 3
48	Toxicología - Sede 4
49	Medicina Forense - Sede 5
50	Dermatología Pediátrica - Sede 6
51	Cardiología Intervencionista - Sede 7
52	Cardiología - Sede 8
53	Dermatología - Sede 1
54	Neurología - Sede 2
55	Oftalmología - Sede 3
56	Endocrinología - Sede 4
57	Geriatría - Sede 5
58	Medicina del Deporte - Sede 6
59	Rehabilitación - Sede 7
60	Cirugía General - Sede 8
61	Cirugía Plástica - Sede 1
62	Anestesiología - Sede 2
63	Radiología - Sede 3
64	Hematología - Sede 4
65	Inmunología - Sede 5
66	Medicina Familiar - Sede 6
67	Odontopediatría - Sede 7
68	Ginecología y Obstetricia - Sede 8
69	Urología - Sede 1
70	Pediatría Neonatal - Sede 2
71	Medicina Laboral - Sede 3
72	Urgencias - Sede 4
73	Medicina Crítica - Sede 5
74	Nutrición - Sede 6
75	Psicología Clínica - Sede 7
76	Fisioterapia - Sede 8
77	Terapia Ocupacional - Sede 1
78	Logopedia - Sede 2
79	Toxicología - Sede 3
80	Medicina Forense - Sede 4
81	Dermatología Pediátrica - Sede 5
82	Cardiología Intervencionista - Sede 6
83	Cardiología - Sede 7
84	Dermatología - Sede 8
85	Neurología - Sede 1
86	Oftalmología - Sede 2
87	Endocrinología - Sede 3
88	Geriatría - Sede 4
89	Medicina del Deporte - Sede 5
90	Rehabilitación - Sede 6
91	Cirugía General - Sede 7
92	Cirugía Plástica - Sede 8
93	Anestesiología - Sede 1
94	Radiología - Sede 2
95	Hematología - Sede 3
96	Inmunología - Sede 4
97	Medicina Familiar - Sede 5
98	Odontopediatría - Sede 6
99	Ginecología y Obstetricia - Sede 7
100	Urología - Sede 8
\.


--
-- Name: appointments_audit_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.appointments_audit_audit_id_seq', 2, true);


--
-- Name: appointments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.appointments_id_seq', 1, false);


--
-- Name: diagnoses_audit_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.diagnoses_audit_audit_id_seq', 33, true);


--
-- Name: diagnoses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.diagnoses_id_seq', 1, false);


--
-- Name: doctors_audit_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.doctors_audit_audit_id_seq', 1, false);


--
-- Name: doctors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.doctors_id_seq', 1, false);


--
-- Name: medicines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.medicines_id_seq', 1, false);


--
-- Name: patients_audit_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.patients_audit_audit_id_seq', 1, false);


--
-- Name: patients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.patients_id_seq', 1, false);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payments_id_seq', 1, false);


--
-- Name: prescriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.prescriptions_id_seq', 1, false);


--
-- Name: procedures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.procedures_id_seq', 1, false);


--
-- Name: recipe_details_audit_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recipe_details_audit_audit_id_seq', 1, false);


--
-- Name: recipe_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recipe_details_id_seq', 1, false);


--
-- Name: sales_audit_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sales_audit_audit_id_seq', 1, false);


--
-- Name: specialties_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.specialties_id_seq', 1, false);


--
-- Name: appointments_audit appointments_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments_audit
    ADD CONSTRAINT appointments_audit_pkey PRIMARY KEY (audit_id);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- Name: diagnoses_audit diagnoses_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnoses_audit
    ADD CONSTRAINT diagnoses_audit_pkey PRIMARY KEY (audit_id);


--
-- Name: diagnoses diagnoses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnoses
    ADD CONSTRAINT diagnoses_pkey PRIMARY KEY (id);


--
-- Name: doctors_audit doctors_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doctors_audit
    ADD CONSTRAINT doctors_audit_pkey PRIMARY KEY (audit_id);


--
-- Name: doctors doctors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_pkey PRIMARY KEY (id);


--
-- Name: medicines medicines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medicines
    ADD CONSTRAINT medicines_pkey PRIMARY KEY (id);


--
-- Name: patients_audit patients_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients_audit
    ADD CONSTRAINT patients_audit_pkey PRIMARY KEY (audit_id);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: prescriptions prescriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_pkey PRIMARY KEY (id);


--
-- Name: procedures procedures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procedures
    ADD CONSTRAINT procedures_pkey PRIMARY KEY (id);


--
-- Name: recipe_details_audit recipe_details_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_details_audit
    ADD CONSTRAINT recipe_details_audit_pkey PRIMARY KEY (audit_id);


--
-- Name: recipe_details recipe_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_details
    ADD CONSTRAINT recipe_details_pkey PRIMARY KEY (id);


--
-- Name: payments_audit sales_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments_audit
    ADD CONSTRAINT sales_audit_pkey PRIMARY KEY (audit_id);


--
-- Name: specialties specialties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.specialties
    ADD CONSTRAINT specialties_pkey PRIMARY KEY (id);


--
-- Name: appointments ad_appointments_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ad_appointments_audit AFTER DELETE ON public.appointments FOR EACH ROW EXECUTE FUNCTION public.appointments_ad_audit();


--
-- Name: appointments ai_appointments_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ai_appointments_audit AFTER INSERT ON public.appointments FOR EACH ROW EXECUTE FUNCTION public.appointments_ai_audit();


--
-- Name: diagnoses ai_diagnoses_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ai_diagnoses_audit AFTER INSERT ON public.diagnoses FOR EACH ROW EXECUTE FUNCTION public.diagnoses_ai_audit();


--
-- Name: doctors ai_doctors_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ai_doctors_audit AFTER INSERT ON public.doctors FOR EACH ROW EXECUTE FUNCTION public.doctors_ai_audit();


--
-- Name: patients ai_patients_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ai_patients_audit AFTER INSERT ON public.patients FOR EACH ROW EXECUTE FUNCTION public.patients_ai_audit();


--
-- Name: payments ai_payments_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ai_payments_audit AFTER INSERT ON public.payments FOR EACH ROW EXECUTE FUNCTION public.payments_ai_audit();


--
-- Name: recipe_details ai_recipe_details_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ai_recipe_details_audit AFTER INSERT ON public.recipe_details FOR EACH ROW EXECUTE FUNCTION public.recipe_details_ai_audit();


--
-- Name: appointments au_appointments_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER au_appointments_audit AFTER UPDATE ON public.appointments FOR EACH ROW EXECUTE FUNCTION public.appointments_au_audit();


--
-- Name: doctors au_doctors_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER au_doctors_audit AFTER UPDATE ON public.doctors FOR EACH ROW EXECUTE FUNCTION public.doctors_au_audit();


--
-- Name: diagnoses au_patients_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER au_patients_audit AFTER UPDATE ON public.diagnoses FOR EACH ROW EXECUTE FUNCTION public.diagnoses_au_audit();


--
-- Name: patients au_patients_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER au_patients_audit AFTER UPDATE ON public.patients FOR EACH ROW EXECUTE FUNCTION public.patients_au_audit();


--
-- Name: payments au_payments_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER au_payments_audit AFTER UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.payments_au_audit();


--
-- Name: recipe_details au_recipe_details_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER au_recipe_details_audit AFTER UPDATE ON public.recipe_details FOR EACH ROW EXECUTE FUNCTION public.recipe_details_au_audit();


--
-- Name: appointments_audit bd_appointments_audit_block; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bd_appointments_audit_block BEFORE DELETE ON public.appointments_audit FOR EACH ROW EXECUTE FUNCTION public.appointments_audit_block_bd();


--
-- Name: diagnoses bd_diagnoses_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bd_diagnoses_audit BEFORE DELETE ON public.diagnoses FOR EACH ROW EXECUTE FUNCTION public.diagnoses_bd_audit();


--
-- Name: diagnoses_audit bd_diagnoses_audit_block; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bd_diagnoses_audit_block BEFORE DELETE ON public.diagnoses_audit FOR EACH ROW EXECUTE FUNCTION public.diagnoses_audit_block_bd();


--
-- Name: doctors bd_doctors_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bd_doctors_audit BEFORE DELETE ON public.doctors FOR EACH ROW EXECUTE FUNCTION public.doctors_bd_audit();


--
-- Name: doctors_audit bd_doctors_audit_block; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bd_doctors_audit_block BEFORE DELETE ON public.doctors_audit FOR EACH ROW EXECUTE FUNCTION public.doctors_audit_block_bd();


--
-- Name: patients bd_patients_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bd_patients_audit BEFORE DELETE ON public.patients FOR EACH ROW EXECUTE FUNCTION public.patients_bd_audit();


--
-- Name: patients_audit bd_patients_audit_block; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bd_patients_audit_block BEFORE DELETE ON public.patients_audit FOR EACH ROW EXECUTE FUNCTION public.patients_audit_block_bd();


--
-- Name: payments bd_payments_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bd_payments_audit BEFORE DELETE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.payments_bd_audit();


--
-- Name: payments_audit bd_payments_audit_block; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bd_payments_audit_block BEFORE DELETE ON public.payments_audit FOR EACH ROW EXECUTE FUNCTION public.payments_audit_block_bd();


--
-- Name: recipe_details bd_recipe_details_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bd_recipe_details_audit BEFORE DELETE ON public.recipe_details FOR EACH ROW EXECUTE FUNCTION public.recipe_details_bd_audit();


--
-- Name: recipe_details_audit bd_recipe_details_audit_block; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bd_recipe_details_audit_block BEFORE DELETE ON public.recipe_details_audit FOR EACH ROW EXECUTE FUNCTION public.recipe_details_audit_block_bd();


--
-- Name: appointments_audit bi_appointments_audit_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bi_appointments_audit_guard BEFORE INSERT ON public.appointments_audit FOR EACH ROW EXECUTE FUNCTION public.appointments_audit_guard_bi();


--
-- Name: diagnoses_audit bi_diagnoses_audit_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bi_diagnoses_audit_guard BEFORE INSERT ON public.diagnoses_audit FOR EACH ROW EXECUTE FUNCTION public.diagnoses_audit_guard_bi();


--
-- Name: doctors_audit bi_doctors_audit_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bi_doctors_audit_guard BEFORE INSERT ON public.doctors_audit FOR EACH ROW EXECUTE FUNCTION public.doctors_audit_guard_bi();


--
-- Name: patients_audit bi_patients_audit_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bi_patients_audit_guard BEFORE INSERT ON public.patients_audit FOR EACH ROW EXECUTE FUNCTION public.patients_audit_guard_bi();


--
-- Name: payments_audit bi_payments_audit_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bi_payments_audit_guard BEFORE INSERT ON public.payments_audit FOR EACH ROW EXECUTE FUNCTION public.payments_audit_guard_bi();


--
-- Name: recipe_details_audit bi_recipe_details_audit_guard; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bi_recipe_details_audit_guard BEFORE INSERT ON public.recipe_details_audit FOR EACH ROW EXECUTE FUNCTION public.recipe_details_audit_guard_bi();


--
-- Name: appointments_audit bu_appointments_audit_block; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bu_appointments_audit_block BEFORE UPDATE ON public.appointments_audit FOR EACH ROW EXECUTE FUNCTION public.appointments_audit_block_bu();


--
-- Name: diagnoses_audit bu_diagnoses_audit_block; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bu_diagnoses_audit_block BEFORE UPDATE ON public.diagnoses_audit FOR EACH ROW EXECUTE FUNCTION public.diagnoses_audit_block_bu();


--
-- Name: doctors_audit bu_doctors_audit_block; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bu_doctors_audit_block BEFORE UPDATE ON public.doctors_audit FOR EACH ROW EXECUTE FUNCTION public.doctors_audit_block_bu();


--
-- Name: patients_audit bu_patients_audit_block; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bu_patients_audit_block BEFORE UPDATE ON public.patients_audit FOR EACH ROW EXECUTE FUNCTION public.patients_audit_block_bu();


--
-- Name: payments_audit bu_payments_audit_block; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bu_payments_audit_block BEFORE UPDATE ON public.payments_audit FOR EACH ROW EXECUTE FUNCTION public.payments_audit_block_bu();


--
-- Name: recipe_details_audit bu_recipe_details_audit_block; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bu_recipe_details_audit_block BEFORE UPDATE ON public.recipe_details_audit FOR EACH ROW EXECUTE FUNCTION public.recipe_details_audit_block_bu();


--
-- Name: appointments appointments_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(id);


--
-- Name: appointments appointments_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: diagnoses diagnoses_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnoses
    ADD CONSTRAINT diagnoses_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id);


--
-- Name: diagnoses diagnoses_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnoses
    ADD CONSTRAINT diagnoses_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: doctors doctors_specialty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_specialty_id_fkey FOREIGN KEY (specialty_id) REFERENCES public.specialties(id);


--
-- Name: payments payments_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id);


--
-- Name: prescriptions prescriptions_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id);


--
-- Name: procedures procedures_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procedures
    ADD CONSTRAINT procedures_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id);


--
-- Name: recipe_details recipe_details_medicine_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_details
    ADD CONSTRAINT recipe_details_medicine_id_fkey FOREIGN KEY (medicine_id) REFERENCES public.medicines(id);


--
-- Name: recipe_details recipe_details_prescription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_details
    ADD CONSTRAINT recipe_details_prescription_id_fkey FOREIGN KEY (prescription_id) REFERENCES public.prescriptions(id);


--
-- PostgreSQL database dump complete
--

\unrestrict V3ru5N3WxMAaH48MCWGdFyOk5Weseha4sOiJXs7Qv4Ovwm64fMgv5rEciu7fSCl

