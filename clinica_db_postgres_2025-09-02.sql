--
-- PostgreSQL database dump
--

\restrict 9d2nfUcq14HISt8f7FeaxGgSZPMeB4e9mnGHgsxGTpEHNaeYYJMxoFA2lmvqFHO

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: appointment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appointment (
    id integer NOT NULL,
    date timestamp without time zone NOT NULL,
    reason character(200) NOT NULL,
    patient integer,
    doctor integer
);


--
-- Name: appointment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.appointment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appointment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.appointment_id_seq OWNED BY public.appointment.id;


--
-- Name: diagnosis; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.diagnosis (
    id integer NOT NULL,
    description character(200) NOT NULL,
    patient integer,
    appointment integer
);


--
-- Name: diagnosis_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.diagnosis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: diagnosis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.diagnosis_id_seq OWNED BY public.diagnosis.id;


--
-- Name: doctor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.doctor (
    id integer NOT NULL,
    name character(50) NOT NULL,
    last_name character(80) NOT NULL,
    telephone character(20) NOT NULL,
    email character(100) NOT NULL,
    specialty integer
);


--
-- Name: doctor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.doctor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: doctor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.doctor_id_seq OWNED BY public.doctor.id;


--
-- Name: medicine; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medicine (
    id integer NOT NULL,
    name character(80) NOT NULL,
    presentation character(50) NOT NULL,
    dose character(50) NOT NULL
);


--
-- Name: medicine_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.medicine_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: medicine_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.medicine_id_seq OWNED BY public.medicine.id;


--
-- Name: patient; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient (
    id integer NOT NULL,
    name character(50) NOT NULL,
    last_name character(80) NOT NULL,
    birth_date date,
    gender character(10),
    address character(40) NOT NULL,
    telephone character(20) NOT NULL,
    CONSTRAINT patient_gender_check CHECK ((gender = ANY (ARRAY['M'::bpchar, 'F'::bpchar, 'Other'::bpchar])))
);


--
-- Name: patient_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.patient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: patient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.patient_id_seq OWNED BY public.patient.id;


--
-- Name: pay; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pay (
    id integer NOT NULL,
    day date NOT NULL,
    amount numeric(10,2) NOT NULL,
    appointment integer
);


--
-- Name: pay_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pay_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pay_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pay_id_seq OWNED BY public.pay.id;


--
-- Name: prescription; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prescription (
    id integer NOT NULL,
    day date NOT NULL,
    appointment integer
);


--
-- Name: prescription_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.prescription_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: prescription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.prescription_id_seq OWNED BY public.prescription.id;


--
-- Name: procedures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.procedures (
    id integer NOT NULL,
    description character(200) NOT NULL,
    appointment integer
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
-- Name: recipe_detail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recipe_detail (
    id integer NOT NULL,
    amount integer NOT NULL,
    indications character(200) NOT NULL,
    prescription integer,
    medicine integer
);


--
-- Name: recipe_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recipe_detail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recipe_detail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recipe_detail_id_seq OWNED BY public.recipe_detail.id;


--
-- Name: specialty; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.specialty (
    id integer NOT NULL,
    name_specialty character(100) NOT NULL
);


--
-- Name: specialty_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.specialty_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: specialty_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.specialty_id_seq OWNED BY public.specialty.id;


--
-- Name: appointment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment ALTER COLUMN id SET DEFAULT nextval('public.appointment_id_seq'::regclass);


--
-- Name: diagnosis id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnosis ALTER COLUMN id SET DEFAULT nextval('public.diagnosis_id_seq'::regclass);


--
-- Name: doctor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doctor ALTER COLUMN id SET DEFAULT nextval('public.doctor_id_seq'::regclass);


--
-- Name: medicine id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medicine ALTER COLUMN id SET DEFAULT nextval('public.medicine_id_seq'::regclass);


--
-- Name: patient id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient ALTER COLUMN id SET DEFAULT nextval('public.patient_id_seq'::regclass);


--
-- Name: pay id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay ALTER COLUMN id SET DEFAULT nextval('public.pay_id_seq'::regclass);


--
-- Name: prescription id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prescription ALTER COLUMN id SET DEFAULT nextval('public.prescription_id_seq'::regclass);


--
-- Name: procedures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procedures ALTER COLUMN id SET DEFAULT nextval('public.procedures_id_seq'::regclass);


--
-- Name: recipe_detail id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_detail ALTER COLUMN id SET DEFAULT nextval('public.recipe_detail_id_seq'::regclass);


--
-- Name: specialty id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.specialty ALTER COLUMN id SET DEFAULT nextval('public.specialty_id_seq'::regclass);


--
-- Data for Name: appointment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.appointment (id, date, reason, patient, doctor) FROM stdin;
\.


--
-- Data for Name: diagnosis; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.diagnosis (id, description, patient, appointment) FROM stdin;
\.


--
-- Data for Name: doctor; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.doctor (id, name, last_name, telephone, email, specialty) FROM stdin;
\.


--
-- Data for Name: medicine; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.medicine (id, name, presentation, dose) FROM stdin;
\.


--
-- Data for Name: patient; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.patient (id, name, last_name, birth_date, gender, address, telephone) FROM stdin;
\.


--
-- Data for Name: pay; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pay (id, day, amount, appointment) FROM stdin;
\.


--
-- Data for Name: prescription; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.prescription (id, day, appointment) FROM stdin;
\.


--
-- Data for Name: procedures; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.procedures (id, description, appointment) FROM stdin;
\.


--
-- Data for Name: recipe_detail; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recipe_detail (id, amount, indications, prescription, medicine) FROM stdin;
\.


--
-- Data for Name: specialty; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.specialty (id, name_specialty) FROM stdin;
\.


--
-- Name: appointment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.appointment_id_seq', 1, false);


--
-- Name: diagnosis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.diagnosis_id_seq', 1, false);


--
-- Name: doctor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.doctor_id_seq', 1, false);


--
-- Name: medicine_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.medicine_id_seq', 1, false);


--
-- Name: patient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.patient_id_seq', 1, false);


--
-- Name: pay_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pay_id_seq', 1, false);


--
-- Name: prescription_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.prescription_id_seq', 1, false);


--
-- Name: procedures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.procedures_id_seq', 1, false);


--
-- Name: recipe_detail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recipe_detail_id_seq', 1, false);


--
-- Name: specialty_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.specialty_id_seq', 1, false);


--
-- Name: appointment appointment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment
    ADD CONSTRAINT appointment_pkey PRIMARY KEY (id);


--
-- Name: diagnosis diagnosis_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnosis
    ADD CONSTRAINT diagnosis_pkey PRIMARY KEY (id);


--
-- Name: doctor doctor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_pkey PRIMARY KEY (id);


--
-- Name: medicine medicine_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medicine
    ADD CONSTRAINT medicine_pkey PRIMARY KEY (id);


--
-- Name: patient patient_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient
    ADD CONSTRAINT patient_pkey PRIMARY KEY (id);


--
-- Name: pay pay_appointment_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay
    ADD CONSTRAINT pay_appointment_key UNIQUE (appointment);


--
-- Name: pay pay_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay
    ADD CONSTRAINT pay_pkey PRIMARY KEY (id);


--
-- Name: prescription prescription_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prescription
    ADD CONSTRAINT prescription_pkey PRIMARY KEY (id);


--
-- Name: procedures procedures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procedures
    ADD CONSTRAINT procedures_pkey PRIMARY KEY (id);


--
-- Name: recipe_detail recipe_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_detail
    ADD CONSTRAINT recipe_detail_pkey PRIMARY KEY (id);


--
-- Name: specialty specialty_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.specialty
    ADD CONSTRAINT specialty_pkey PRIMARY KEY (id);


--
-- Name: appointment appointment_doctor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment
    ADD CONSTRAINT appointment_doctor_fkey FOREIGN KEY (doctor) REFERENCES public.doctor(id);


--
-- Name: appointment appointment_patient_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment
    ADD CONSTRAINT appointment_patient_fkey FOREIGN KEY (patient) REFERENCES public.patient(id);


--
-- Name: diagnosis diagnosis_appointment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnosis
    ADD CONSTRAINT diagnosis_appointment_fkey FOREIGN KEY (appointment) REFERENCES public.appointment(id);


--
-- Name: diagnosis diagnosis_patient_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnosis
    ADD CONSTRAINT diagnosis_patient_fkey FOREIGN KEY (patient) REFERENCES public.patient(id);


--
-- Name: doctor doctor_specialty_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_specialty_fkey FOREIGN KEY (specialty) REFERENCES public.specialty(id);


--
-- Name: pay pay_appointment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay
    ADD CONSTRAINT pay_appointment_fkey FOREIGN KEY (appointment) REFERENCES public.appointment(id);


--
-- Name: prescription prescription_appointment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prescription
    ADD CONSTRAINT prescription_appointment_fkey FOREIGN KEY (appointment) REFERENCES public.appointment(id);


--
-- Name: procedures procedures_appointment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.procedures
    ADD CONSTRAINT procedures_appointment_fkey FOREIGN KEY (appointment) REFERENCES public.appointment(id);


--
-- Name: recipe_detail recipe_detail_medicine_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_detail
    ADD CONSTRAINT recipe_detail_medicine_fkey FOREIGN KEY (medicine) REFERENCES public.medicine(id);


--
-- Name: recipe_detail recipe_detail_prescription_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_detail
    ADD CONSTRAINT recipe_detail_prescription_fkey FOREIGN KEY (prescription) REFERENCES public.prescription(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 9d2nfUcq14HISt8f7FeaxGgSZPMeB4e9mnGHgsxGTpEHNaeYYJMxoFA2lmvqFHO

