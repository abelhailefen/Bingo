--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

-- Started on 2026-01-31 23:46:11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 233 (class 1255 OID 24849)
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 225 (class 1259 OID 24941)
-- Name: called_numbers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.called_numbers (
    called_id bigint NOT NULL,
    room_id bigint NOT NULL,
    number integer NOT NULL,
    called_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.called_numbers OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 24940)
-- Name: called_numbers_called_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.called_numbers ALTER COLUMN called_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.called_numbers_called_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 223 (class 1259 OID 24908)
-- Name: cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cards (
    card_id bigint NOT NULL,
    room_id bigint NOT NULL,
    user_id bigint NOT NULL,
    purchased_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    master_card_id bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.cards OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 24907)
-- Name: cards_card_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.cards ALTER COLUMN card_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cards_card_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 230 (class 1259 OID 30228)
-- Name: master_card_numbers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.master_card_numbers (
    master_card_number_id bigint NOT NULL,
    master_card_id bigint NOT NULL,
    position_row integer NOT NULL,
    position_col integer NOT NULL,
    number integer
);


ALTER TABLE public.master_card_numbers OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 30227)
-- Name: master_card_numbers_master_card_number_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.master_card_numbers ALTER COLUMN master_card_number_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.master_card_numbers_master_card_number_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 228 (class 1259 OID 30222)
-- Name: master_cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.master_cards (
    master_card_id bigint NOT NULL
);


ALTER TABLE public.master_cards OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 42050)
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    payment_id bigint NOT NULL,
    user_id bigint NOT NULL,
    transaction_reference character varying(100) NOT NULL,
    amount numeric(10,2) NOT NULL,
    provider integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 42049)
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.payments ALTER COLUMN payment_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.payments_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 221 (class 1259 OID 24888)
-- Name: room_players; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.room_players (
    room_player_id bigint NOT NULL,
    room_id bigint NOT NULL,
    user_id bigint NOT NULL,
    joined_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_ready boolean DEFAULT false
);


ALTER TABLE public.room_players OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 24887)
-- Name: room_players_room_player_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.room_players ALTER COLUMN room_player_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.room_players_room_player_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 219 (class 1259 OID 24870)
-- Name: rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rooms (
    room_id bigint NOT NULL,
    room_code character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    status integer DEFAULT 0,
    max_players integer DEFAULT 100,
    card_price numeric(8,2) DEFAULT 0.00,
    pattern integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    started_at timestamp with time zone,
    ended_at timestamp with time zone,
    scheduled_start_time timestamp with time zone
);


ALTER TABLE public.rooms OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 24869)
-- Name: rooms_room_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.rooms ALTER COLUMN room_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rooms_room_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 217 (class 1259 OID 24837)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id bigint NOT NULL,
    username character varying(50) NOT NULL,
    phone_number character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    balance numeric(10,2) DEFAULT 0.00,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 24964)
-- Name: wins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wins (
    win_id bigint NOT NULL,
    room_id bigint NOT NULL,
    card_id bigint NOT NULL,
    user_id bigint NOT NULL,
    claimed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    verified boolean DEFAULT false,
    verified_at timestamp with time zone,
    prize numeric(10,2) DEFAULT 0.00,
    win_type integer DEFAULT 0
);


ALTER TABLE public.wins OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 24963)
-- Name: wins_win_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.wins ALTER COLUMN win_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.wins_win_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 4903 (class 0 OID 24941)
-- Dependencies: 225
-- Data for Name: called_numbers; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4901 (class 0 OID 24908)
-- Dependencies: 223
-- Data for Name: cards; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4908 (class 0 OID 30228)
-- Dependencies: 230
-- Data for Name: master_card_numbers; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7501, 1, 1, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7502, 1, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7503, 1, 3, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7504, 1, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7505, 1, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7506, 1, 1, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7507, 1, 2, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7508, 1, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7509, 1, 4, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7510, 1, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7511, 1, 1, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7512, 1, 2, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7513, 1, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7514, 1, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7515, 1, 5, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7516, 1, 1, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7517, 1, 2, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7518, 1, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7519, 1, 4, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7520, 1, 5, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7521, 1, 1, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7522, 1, 2, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7523, 1, 3, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7524, 1, 4, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7525, 1, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7526, 2, 1, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7527, 2, 2, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7528, 2, 3, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7529, 2, 4, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7530, 2, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7531, 2, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7532, 2, 2, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7533, 2, 3, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7534, 2, 4, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7535, 2, 5, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7536, 2, 1, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7537, 2, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7538, 2, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7539, 2, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7540, 2, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7541, 2, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7542, 2, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7543, 2, 3, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7544, 2, 4, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7545, 2, 5, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7546, 2, 1, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7547, 2, 2, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7548, 2, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7549, 2, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7550, 2, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7551, 3, 1, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7552, 3, 2, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7553, 3, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7554, 3, 4, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7555, 3, 5, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7556, 3, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7557, 3, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7558, 3, 3, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7559, 3, 4, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7560, 3, 5, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7561, 3, 1, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7562, 3, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7563, 3, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7564, 3, 4, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7565, 3, 5, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7566, 3, 1, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7567, 3, 2, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7568, 3, 3, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7569, 3, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7570, 3, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7571, 3, 1, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7572, 3, 2, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7573, 3, 3, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7574, 3, 4, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7575, 3, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7576, 4, 1, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7577, 4, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7578, 4, 3, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7579, 4, 4, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7580, 4, 5, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7581, 4, 1, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7582, 4, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7583, 4, 3, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7584, 4, 4, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7585, 4, 5, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7586, 4, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7587, 4, 2, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7588, 4, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7589, 4, 4, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7590, 4, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7591, 4, 1, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7592, 4, 2, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7593, 4, 3, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7594, 4, 4, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7595, 4, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7596, 4, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7597, 4, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7598, 4, 3, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7599, 4, 4, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7600, 4, 5, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7601, 5, 1, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7602, 5, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7603, 5, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7604, 5, 4, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7605, 5, 5, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7606, 5, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7607, 5, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7608, 5, 3, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7609, 5, 4, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7610, 5, 5, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7611, 5, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7612, 5, 2, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7613, 5, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7614, 5, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7615, 5, 5, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7616, 5, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7617, 5, 2, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7618, 5, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7619, 5, 4, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7620, 5, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7621, 5, 1, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7622, 5, 2, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7623, 5, 3, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7624, 5, 4, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7625, 5, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7626, 6, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7627, 6, 2, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7628, 6, 3, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7629, 6, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7630, 6, 5, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7631, 6, 1, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7632, 6, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7633, 6, 3, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7634, 6, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7635, 6, 5, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7636, 6, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7637, 6, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7638, 6, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7639, 6, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7640, 6, 5, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7641, 6, 1, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7642, 6, 2, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7643, 6, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7644, 6, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7645, 6, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7646, 6, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7647, 6, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7648, 6, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7649, 6, 4, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7650, 6, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7651, 7, 1, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7652, 7, 2, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7653, 7, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7654, 7, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7655, 7, 5, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7656, 7, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7657, 7, 2, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7658, 7, 3, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7659, 7, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7660, 7, 5, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7661, 7, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7662, 7, 2, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7663, 7, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7664, 7, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7665, 7, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7666, 7, 1, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7667, 7, 2, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7668, 7, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7669, 7, 4, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7670, 7, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7671, 7, 1, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7672, 7, 2, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7673, 7, 3, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7674, 7, 4, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7675, 7, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7676, 8, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7677, 8, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7678, 8, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7679, 8, 4, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7680, 8, 5, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7681, 8, 1, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7682, 8, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7683, 8, 3, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7684, 8, 4, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7685, 8, 5, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7686, 8, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7687, 8, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7688, 8, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7689, 8, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7690, 8, 5, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7691, 8, 1, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7692, 8, 2, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7693, 8, 3, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7694, 8, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7695, 8, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7696, 8, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7697, 8, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7698, 8, 3, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7699, 8, 4, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7700, 8, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7701, 9, 1, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7702, 9, 2, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7703, 9, 3, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7704, 9, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7705, 9, 5, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7706, 9, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7707, 9, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7708, 9, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7709, 9, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7710, 9, 5, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7711, 9, 1, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7712, 9, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7713, 9, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7714, 9, 4, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7715, 9, 5, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7716, 9, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7717, 9, 2, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7718, 9, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7719, 9, 4, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7720, 9, 5, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7721, 9, 1, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7722, 9, 2, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7723, 9, 3, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7724, 9, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7725, 9, 5, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7726, 10, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7727, 10, 2, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7728, 10, 3, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7729, 10, 4, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7730, 10, 5, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7731, 10, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7732, 10, 2, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7733, 10, 3, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7734, 10, 4, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7735, 10, 5, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7736, 10, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7737, 10, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7738, 10, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7739, 10, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7740, 10, 5, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7741, 10, 1, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7742, 10, 2, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7743, 10, 3, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7744, 10, 4, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7745, 10, 5, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7746, 10, 1, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7747, 10, 2, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7748, 10, 3, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7749, 10, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7750, 10, 5, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7751, 11, 1, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7752, 11, 2, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7753, 11, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7754, 11, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7755, 11, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7756, 11, 1, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7757, 11, 2, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7758, 11, 3, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7759, 11, 4, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7760, 11, 5, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7761, 11, 1, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7762, 11, 2, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7763, 11, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7764, 11, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7765, 11, 5, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7766, 11, 1, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7767, 11, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7768, 11, 3, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7769, 11, 4, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7770, 11, 5, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7771, 11, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7772, 11, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7773, 11, 3, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7774, 11, 4, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7775, 11, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7776, 12, 1, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7777, 12, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7778, 12, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7779, 12, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7780, 12, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7781, 12, 1, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7782, 12, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7783, 12, 3, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7784, 12, 4, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7785, 12, 5, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7786, 12, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7787, 12, 2, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7788, 12, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7789, 12, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7790, 12, 5, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7791, 12, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7792, 12, 2, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7793, 12, 3, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7794, 12, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7795, 12, 5, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7796, 12, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7797, 12, 2, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7798, 12, 3, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7799, 12, 4, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7800, 12, 5, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7801, 13, 1, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7802, 13, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7803, 13, 3, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7804, 13, 4, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7805, 13, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7806, 13, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7807, 13, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7808, 13, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7809, 13, 4, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7810, 13, 5, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7811, 13, 1, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7812, 13, 2, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7813, 13, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7814, 13, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7815, 13, 5, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7816, 13, 1, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7817, 13, 2, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7818, 13, 3, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7819, 13, 4, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7820, 13, 5, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7821, 13, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7822, 13, 2, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7823, 13, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7824, 13, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7825, 13, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7826, 14, 1, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7827, 14, 2, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7828, 14, 3, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7829, 14, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7830, 14, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7831, 14, 1, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7832, 14, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7833, 14, 3, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7834, 14, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7835, 14, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7836, 14, 1, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7837, 14, 2, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7838, 14, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7839, 14, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7840, 14, 5, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7841, 14, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7842, 14, 2, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7843, 14, 3, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7844, 14, 4, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7845, 14, 5, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7846, 14, 1, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7847, 14, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7848, 14, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7849, 14, 4, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7850, 14, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7851, 15, 1, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7852, 15, 2, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7853, 15, 3, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7854, 15, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7855, 15, 5, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7856, 15, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7857, 15, 2, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7858, 15, 3, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7859, 15, 4, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7860, 15, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7861, 15, 1, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7862, 15, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7863, 15, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7864, 15, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7865, 15, 5, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7866, 15, 1, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7867, 15, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7868, 15, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7869, 15, 4, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7870, 15, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7871, 15, 1, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7872, 15, 2, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7873, 15, 3, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7874, 15, 4, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7875, 15, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7876, 16, 1, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7877, 16, 2, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7878, 16, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7879, 16, 4, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7880, 16, 5, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7881, 16, 1, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7882, 16, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7883, 16, 3, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7884, 16, 4, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7885, 16, 5, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7886, 16, 1, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7887, 16, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7888, 16, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7889, 16, 4, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7890, 16, 5, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7891, 16, 1, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7892, 16, 2, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7893, 16, 3, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7894, 16, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7895, 16, 5, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7896, 16, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7897, 16, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7898, 16, 3, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7899, 16, 4, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7900, 16, 5, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7901, 17, 1, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7902, 17, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7903, 17, 3, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7904, 17, 4, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7905, 17, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7906, 17, 1, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7907, 17, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7908, 17, 3, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7909, 17, 4, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7910, 17, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7911, 17, 1, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7912, 17, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7913, 17, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7914, 17, 4, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7915, 17, 5, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7916, 17, 1, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7917, 17, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7918, 17, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7919, 17, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7920, 17, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7921, 17, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7922, 17, 2, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7923, 17, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7924, 17, 4, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7925, 17, 5, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7926, 18, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7927, 18, 2, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7928, 18, 3, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7929, 18, 4, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7930, 18, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7931, 18, 1, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7932, 18, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7933, 18, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7934, 18, 4, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7935, 18, 5, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7936, 18, 1, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7937, 18, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7938, 18, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7939, 18, 4, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7940, 18, 5, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7941, 18, 1, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7942, 18, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7943, 18, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7944, 18, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7945, 18, 5, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7946, 18, 1, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7947, 18, 2, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7948, 18, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7949, 18, 4, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7950, 18, 5, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7951, 19, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7952, 19, 2, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7953, 19, 3, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7954, 19, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7955, 19, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7956, 19, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7957, 19, 2, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7958, 19, 3, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7959, 19, 4, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7960, 19, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7961, 19, 1, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7962, 19, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7963, 19, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7964, 19, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7965, 19, 5, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7966, 19, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7967, 19, 2, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7968, 19, 3, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7969, 19, 4, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7970, 19, 5, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7971, 19, 1, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7972, 19, 2, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7973, 19, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7974, 19, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7975, 19, 5, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7976, 20, 1, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7977, 20, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7978, 20, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7979, 20, 4, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7980, 20, 5, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7981, 20, 1, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7982, 20, 2, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7983, 20, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7984, 20, 4, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7985, 20, 5, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7986, 20, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7987, 20, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7988, 20, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7989, 20, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7990, 20, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7991, 20, 1, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7992, 20, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7993, 20, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7994, 20, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7995, 20, 5, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7996, 20, 1, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7997, 20, 2, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7998, 20, 3, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (7999, 20, 4, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8000, 20, 5, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8001, 21, 1, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8002, 21, 2, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8003, 21, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8004, 21, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8005, 21, 5, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8006, 21, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8007, 21, 2, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8008, 21, 3, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8009, 21, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8010, 21, 5, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8011, 21, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8012, 21, 2, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8013, 21, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8014, 21, 4, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8015, 21, 5, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8016, 21, 1, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8017, 21, 2, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8018, 21, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8019, 21, 4, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8020, 21, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8021, 21, 1, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8022, 21, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8023, 21, 3, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8024, 21, 4, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8025, 21, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8026, 22, 1, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8027, 22, 2, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8028, 22, 3, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8029, 22, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8030, 22, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8031, 22, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8032, 22, 2, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8033, 22, 3, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8034, 22, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8035, 22, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8036, 22, 1, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8037, 22, 2, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8038, 22, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8039, 22, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8040, 22, 5, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8041, 22, 1, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8042, 22, 2, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8043, 22, 3, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8044, 22, 4, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8045, 22, 5, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8046, 22, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8047, 22, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8048, 22, 3, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8049, 22, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8050, 22, 5, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8051, 23, 1, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8052, 23, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8053, 23, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8054, 23, 4, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8055, 23, 5, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8056, 23, 1, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8057, 23, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8058, 23, 3, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8059, 23, 4, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8060, 23, 5, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8061, 23, 1, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8062, 23, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8063, 23, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8064, 23, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8065, 23, 5, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8066, 23, 1, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8067, 23, 2, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8068, 23, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8069, 23, 4, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8070, 23, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8071, 23, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8072, 23, 2, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8073, 23, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8074, 23, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8075, 23, 5, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8076, 24, 1, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8077, 24, 2, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8078, 24, 3, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8079, 24, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8080, 24, 5, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8081, 24, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8082, 24, 2, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8083, 24, 3, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8084, 24, 4, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8085, 24, 5, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8086, 24, 1, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8087, 24, 2, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8088, 24, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8089, 24, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8090, 24, 5, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8091, 24, 1, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8092, 24, 2, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8093, 24, 3, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8094, 24, 4, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8095, 24, 5, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8096, 24, 1, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8097, 24, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8098, 24, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8099, 24, 4, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8100, 24, 5, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8101, 25, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8102, 25, 2, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8103, 25, 3, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8104, 25, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8105, 25, 5, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8106, 25, 1, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8107, 25, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8108, 25, 3, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8109, 25, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8110, 25, 5, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8111, 25, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8112, 25, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8113, 25, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8114, 25, 4, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8115, 25, 5, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8116, 25, 1, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8117, 25, 2, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8118, 25, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8119, 25, 4, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8120, 25, 5, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8121, 25, 1, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8122, 25, 2, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8123, 25, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8124, 25, 4, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8125, 25, 5, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8126, 26, 1, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8127, 26, 2, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8128, 26, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8129, 26, 4, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8130, 26, 5, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8131, 26, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8132, 26, 2, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8133, 26, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8134, 26, 4, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8135, 26, 5, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8136, 26, 1, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8137, 26, 2, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8138, 26, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8139, 26, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8140, 26, 5, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8141, 26, 1, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8142, 26, 2, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8143, 26, 3, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8144, 26, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8145, 26, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8146, 26, 1, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8147, 26, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8148, 26, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8149, 26, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8150, 26, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8151, 27, 1, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8152, 27, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8153, 27, 3, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8154, 27, 4, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8155, 27, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8156, 27, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8157, 27, 2, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8158, 27, 3, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8159, 27, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8160, 27, 5, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8161, 27, 1, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8162, 27, 2, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8163, 27, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8164, 27, 4, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8165, 27, 5, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8166, 27, 1, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8167, 27, 2, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8168, 27, 3, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8169, 27, 4, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8170, 27, 5, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8171, 27, 1, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8172, 27, 2, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8173, 27, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8174, 27, 4, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8175, 27, 5, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8176, 28, 1, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8177, 28, 2, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8178, 28, 3, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8179, 28, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8180, 28, 5, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8181, 28, 1, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8182, 28, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8183, 28, 3, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8184, 28, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8185, 28, 5, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8186, 28, 1, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8187, 28, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8188, 28, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8189, 28, 4, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8190, 28, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8191, 28, 1, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8192, 28, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8193, 28, 3, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8194, 28, 4, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8195, 28, 5, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8196, 28, 1, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8197, 28, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8198, 28, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8199, 28, 4, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8200, 28, 5, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8201, 29, 1, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8202, 29, 2, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8203, 29, 3, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8204, 29, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8205, 29, 5, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8206, 29, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8207, 29, 2, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8208, 29, 3, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8209, 29, 4, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8210, 29, 5, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8211, 29, 1, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8212, 29, 2, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8213, 29, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8214, 29, 4, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8215, 29, 5, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8216, 29, 1, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8217, 29, 2, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8218, 29, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8219, 29, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8220, 29, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8221, 29, 1, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8222, 29, 2, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8223, 29, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8224, 29, 4, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8225, 29, 5, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8226, 30, 1, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8227, 30, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8228, 30, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8229, 30, 4, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8230, 30, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8231, 30, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8232, 30, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8233, 30, 3, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8234, 30, 4, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8235, 30, 5, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8236, 30, 1, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8237, 30, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8238, 30, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8239, 30, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8240, 30, 5, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8241, 30, 1, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8242, 30, 2, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8243, 30, 3, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8244, 30, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8245, 30, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8246, 30, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8247, 30, 2, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8248, 30, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8249, 30, 4, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8250, 30, 5, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8251, 31, 1, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8252, 31, 2, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8253, 31, 3, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8254, 31, 4, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8255, 31, 5, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8256, 31, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8257, 31, 2, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8258, 31, 3, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8259, 31, 4, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8260, 31, 5, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8261, 31, 1, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8262, 31, 2, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8263, 31, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8264, 31, 4, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8265, 31, 5, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8266, 31, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8267, 31, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8268, 31, 3, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8269, 31, 4, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8270, 31, 5, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8271, 31, 1, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8272, 31, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8273, 31, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8274, 31, 4, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8275, 31, 5, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8276, 32, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8277, 32, 2, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8278, 32, 3, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8279, 32, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8280, 32, 5, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8281, 32, 1, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8282, 32, 2, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8283, 32, 3, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8284, 32, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8285, 32, 5, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8286, 32, 1, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8287, 32, 2, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8288, 32, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8289, 32, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8290, 32, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8291, 32, 1, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8292, 32, 2, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8293, 32, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8294, 32, 4, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8295, 32, 5, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8296, 32, 1, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8297, 32, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8298, 32, 3, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8299, 32, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8300, 32, 5, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8301, 33, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8302, 33, 2, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8303, 33, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8304, 33, 4, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8305, 33, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8306, 33, 1, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8307, 33, 2, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8308, 33, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8309, 33, 4, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8310, 33, 5, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8311, 33, 1, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8312, 33, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8313, 33, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8314, 33, 4, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8315, 33, 5, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8316, 33, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8317, 33, 2, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8318, 33, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8319, 33, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8320, 33, 5, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8321, 33, 1, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8322, 33, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8323, 33, 3, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8324, 33, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8325, 33, 5, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8326, 34, 1, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8327, 34, 2, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8328, 34, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8329, 34, 4, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8330, 34, 5, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8331, 34, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8332, 34, 2, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8333, 34, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8334, 34, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8335, 34, 5, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8336, 34, 1, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8337, 34, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8338, 34, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8339, 34, 4, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8340, 34, 5, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8341, 34, 1, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8342, 34, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8343, 34, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8344, 34, 4, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8345, 34, 5, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8346, 34, 1, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8347, 34, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8348, 34, 3, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8349, 34, 4, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8350, 34, 5, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8351, 35, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8352, 35, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8353, 35, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8354, 35, 4, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8355, 35, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8356, 35, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8357, 35, 2, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8358, 35, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8359, 35, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8360, 35, 5, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8361, 35, 1, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8362, 35, 2, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8363, 35, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8364, 35, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8365, 35, 5, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8366, 35, 1, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8367, 35, 2, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8368, 35, 3, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8369, 35, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8370, 35, 5, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8371, 35, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8372, 35, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8373, 35, 3, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8374, 35, 4, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8375, 35, 5, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8376, 36, 1, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8377, 36, 2, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8378, 36, 3, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8379, 36, 4, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8380, 36, 5, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8381, 36, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8382, 36, 2, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8383, 36, 3, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8384, 36, 4, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8385, 36, 5, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8386, 36, 1, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8387, 36, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8388, 36, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8389, 36, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8390, 36, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8391, 36, 1, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8392, 36, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8393, 36, 3, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8394, 36, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8395, 36, 5, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8396, 36, 1, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8397, 36, 2, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8398, 36, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8399, 36, 4, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8400, 36, 5, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8401, 37, 1, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8402, 37, 2, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8403, 37, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8404, 37, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8405, 37, 5, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8406, 37, 1, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8407, 37, 2, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8408, 37, 3, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8409, 37, 4, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8410, 37, 5, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8411, 37, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8412, 37, 2, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8413, 37, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8414, 37, 4, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8415, 37, 5, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8416, 37, 1, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8417, 37, 2, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8418, 37, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8419, 37, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8420, 37, 5, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8421, 37, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8422, 37, 2, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8423, 37, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8424, 37, 4, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8425, 37, 5, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8426, 38, 1, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8427, 38, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8428, 38, 3, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8429, 38, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8430, 38, 5, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8431, 38, 1, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8432, 38, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8433, 38, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8434, 38, 4, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8435, 38, 5, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8436, 38, 1, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8437, 38, 2, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8438, 38, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8439, 38, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8440, 38, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8441, 38, 1, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8442, 38, 2, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8443, 38, 3, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8444, 38, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8445, 38, 5, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8446, 38, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8447, 38, 2, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8448, 38, 3, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8449, 38, 4, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8450, 38, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8451, 39, 1, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8452, 39, 2, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8453, 39, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8454, 39, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8455, 39, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8456, 39, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8457, 39, 2, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8458, 39, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8459, 39, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8460, 39, 5, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8461, 39, 1, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8462, 39, 2, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8463, 39, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8464, 39, 4, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8465, 39, 5, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8466, 39, 1, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8467, 39, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8468, 39, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8469, 39, 4, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8470, 39, 5, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8471, 39, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8472, 39, 2, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8473, 39, 3, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8474, 39, 4, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8475, 39, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8476, 40, 1, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8477, 40, 2, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8478, 40, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8479, 40, 4, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8480, 40, 5, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8481, 40, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8482, 40, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8483, 40, 3, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8484, 40, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8485, 40, 5, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8486, 40, 1, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8487, 40, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8488, 40, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8489, 40, 4, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8490, 40, 5, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8491, 40, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8492, 40, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8493, 40, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8494, 40, 4, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8495, 40, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8496, 40, 1, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8497, 40, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8498, 40, 3, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8499, 40, 4, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8500, 40, 5, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8501, 41, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8502, 41, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8503, 41, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8504, 41, 4, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8505, 41, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8506, 41, 1, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8507, 41, 2, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8508, 41, 3, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8509, 41, 4, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8510, 41, 5, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8511, 41, 1, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8512, 41, 2, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8513, 41, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8514, 41, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8515, 41, 5, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8516, 41, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8517, 41, 2, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8518, 41, 3, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8519, 41, 4, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8520, 41, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8521, 41, 1, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8522, 41, 2, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8523, 41, 3, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8524, 41, 4, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8525, 41, 5, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8526, 42, 1, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8527, 42, 2, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8528, 42, 3, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8529, 42, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8530, 42, 5, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8531, 42, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8532, 42, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8533, 42, 3, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8534, 42, 4, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8535, 42, 5, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8536, 42, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8537, 42, 2, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8538, 42, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8539, 42, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8540, 42, 5, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8541, 42, 1, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8542, 42, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8543, 42, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8544, 42, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8545, 42, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8546, 42, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8547, 42, 2, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8548, 42, 3, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8549, 42, 4, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8550, 42, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8551, 43, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8552, 43, 2, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8553, 43, 3, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8554, 43, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8555, 43, 5, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8556, 43, 1, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8557, 43, 2, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8558, 43, 3, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8559, 43, 4, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8560, 43, 5, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8561, 43, 1, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8562, 43, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8563, 43, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8564, 43, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8565, 43, 5, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8566, 43, 1, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8567, 43, 2, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8568, 43, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8569, 43, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8570, 43, 5, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8571, 43, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8572, 43, 2, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8573, 43, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8574, 43, 4, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8575, 43, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8576, 44, 1, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8577, 44, 2, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8578, 44, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8579, 44, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8580, 44, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8581, 44, 1, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8582, 44, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8583, 44, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8584, 44, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8585, 44, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8586, 44, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8587, 44, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8588, 44, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8589, 44, 4, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8590, 44, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8591, 44, 1, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8592, 44, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8593, 44, 3, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8594, 44, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8595, 44, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8596, 44, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8597, 44, 2, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8598, 44, 3, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8599, 44, 4, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8600, 44, 5, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8601, 45, 1, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8602, 45, 2, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8603, 45, 3, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8604, 45, 4, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8605, 45, 5, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8606, 45, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8607, 45, 2, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8608, 45, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8609, 45, 4, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8610, 45, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8611, 45, 1, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8612, 45, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8613, 45, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8614, 45, 4, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8615, 45, 5, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8616, 45, 1, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8617, 45, 2, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8618, 45, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8619, 45, 4, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8620, 45, 5, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8621, 45, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8622, 45, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8623, 45, 3, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8624, 45, 4, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8625, 45, 5, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8626, 46, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8627, 46, 2, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8628, 46, 3, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8629, 46, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8630, 46, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8631, 46, 1, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8632, 46, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8633, 46, 3, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8634, 46, 4, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8635, 46, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8636, 46, 1, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8637, 46, 2, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8638, 46, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8639, 46, 4, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8640, 46, 5, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8641, 46, 1, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8642, 46, 2, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8643, 46, 3, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8644, 46, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8645, 46, 5, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8646, 46, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8647, 46, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8648, 46, 3, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8649, 46, 4, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8650, 46, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8651, 47, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8652, 47, 2, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8653, 47, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8654, 47, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8655, 47, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8656, 47, 1, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8657, 47, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8658, 47, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8659, 47, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8660, 47, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8661, 47, 1, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8662, 47, 2, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8663, 47, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8664, 47, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8665, 47, 5, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8666, 47, 1, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8667, 47, 2, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8668, 47, 3, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8669, 47, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8670, 47, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8671, 47, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8672, 47, 2, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8673, 47, 3, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8674, 47, 4, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8675, 47, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8676, 48, 1, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8677, 48, 2, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8678, 48, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8679, 48, 4, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8680, 48, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8681, 48, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8682, 48, 2, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8683, 48, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8684, 48, 4, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8685, 48, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8686, 48, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8687, 48, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8688, 48, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8689, 48, 4, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8690, 48, 5, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8691, 48, 1, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8692, 48, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8693, 48, 3, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8694, 48, 4, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8695, 48, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8696, 48, 1, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8697, 48, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8698, 48, 3, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8699, 48, 4, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8700, 48, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8701, 49, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8702, 49, 2, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8703, 49, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8704, 49, 4, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8705, 49, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8706, 49, 1, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8707, 49, 2, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8708, 49, 3, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8709, 49, 4, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8710, 49, 5, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8711, 49, 1, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8712, 49, 2, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8713, 49, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8714, 49, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8715, 49, 5, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8716, 49, 1, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8717, 49, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8718, 49, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8719, 49, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8720, 49, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8721, 49, 1, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8722, 49, 2, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8723, 49, 3, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8724, 49, 4, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8725, 49, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8726, 50, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8727, 50, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8728, 50, 3, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8729, 50, 4, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8730, 50, 5, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8731, 50, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8732, 50, 2, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8733, 50, 3, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8734, 50, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8735, 50, 5, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8736, 50, 1, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8737, 50, 2, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8738, 50, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8739, 50, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8740, 50, 5, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8741, 50, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8742, 50, 2, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8743, 50, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8744, 50, 4, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8745, 50, 5, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8746, 50, 1, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8747, 50, 2, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8748, 50, 3, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8749, 50, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8750, 50, 5, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8751, 51, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8752, 51, 2, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8753, 51, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8754, 51, 4, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8755, 51, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8756, 51, 1, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8757, 51, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8758, 51, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8759, 51, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8760, 51, 5, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8761, 51, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8762, 51, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8763, 51, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8764, 51, 4, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8765, 51, 5, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8766, 51, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8767, 51, 2, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8768, 51, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8769, 51, 4, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8770, 51, 5, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8771, 51, 1, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8772, 51, 2, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8773, 51, 3, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8774, 51, 4, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8775, 51, 5, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8776, 52, 1, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8777, 52, 2, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8778, 52, 3, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8779, 52, 4, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8780, 52, 5, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8781, 52, 1, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8782, 52, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8783, 52, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8784, 52, 4, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8785, 52, 5, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8786, 52, 1, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8787, 52, 2, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8788, 52, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8789, 52, 4, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8790, 52, 5, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8791, 52, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8792, 52, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8793, 52, 3, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8794, 52, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8795, 52, 5, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8796, 52, 1, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8797, 52, 2, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8798, 52, 3, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8799, 52, 4, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8800, 52, 5, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8801, 53, 1, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8802, 53, 2, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8803, 53, 3, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8804, 53, 4, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8805, 53, 5, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8806, 53, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8807, 53, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8808, 53, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8809, 53, 4, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8810, 53, 5, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8811, 53, 1, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8812, 53, 2, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8813, 53, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8814, 53, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8815, 53, 5, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8816, 53, 1, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8817, 53, 2, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8818, 53, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8819, 53, 4, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8820, 53, 5, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8821, 53, 1, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8822, 53, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8823, 53, 3, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8824, 53, 4, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8825, 53, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8826, 54, 1, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8827, 54, 2, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8828, 54, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8829, 54, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8830, 54, 5, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8831, 54, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8832, 54, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8833, 54, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8834, 54, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8835, 54, 5, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8836, 54, 1, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8837, 54, 2, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8838, 54, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8839, 54, 4, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8840, 54, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8841, 54, 1, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8842, 54, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8843, 54, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8844, 54, 4, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8845, 54, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8846, 54, 1, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8847, 54, 2, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8848, 54, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8849, 54, 4, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8850, 54, 5, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8851, 55, 1, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8852, 55, 2, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8853, 55, 3, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8854, 55, 4, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8855, 55, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8856, 55, 1, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8857, 55, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8858, 55, 3, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8859, 55, 4, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8860, 55, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8861, 55, 1, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8862, 55, 2, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8863, 55, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8864, 55, 4, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8865, 55, 5, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8866, 55, 1, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8867, 55, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8868, 55, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8869, 55, 4, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8870, 55, 5, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8871, 55, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8872, 55, 2, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8873, 55, 3, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8874, 55, 4, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8875, 55, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8876, 56, 1, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8877, 56, 2, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8878, 56, 3, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8879, 56, 4, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8880, 56, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8881, 56, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8882, 56, 2, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8883, 56, 3, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8884, 56, 4, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8885, 56, 5, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8886, 56, 1, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8887, 56, 2, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8888, 56, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8889, 56, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8890, 56, 5, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8891, 56, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8892, 56, 2, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8893, 56, 3, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8894, 56, 4, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8895, 56, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8896, 56, 1, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8897, 56, 2, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8898, 56, 3, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8899, 56, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8900, 56, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8901, 57, 1, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8902, 57, 2, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8903, 57, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8904, 57, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8905, 57, 5, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8906, 57, 1, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8907, 57, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8908, 57, 3, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8909, 57, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8910, 57, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8911, 57, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8912, 57, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8913, 57, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8914, 57, 4, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8915, 57, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8916, 57, 1, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8917, 57, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8918, 57, 3, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8919, 57, 4, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8920, 57, 5, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8921, 57, 1, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8922, 57, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8923, 57, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8924, 57, 4, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8925, 57, 5, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8926, 58, 1, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8927, 58, 2, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8928, 58, 3, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8929, 58, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8930, 58, 5, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8931, 58, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8932, 58, 2, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8933, 58, 3, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8934, 58, 4, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8935, 58, 5, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8936, 58, 1, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8937, 58, 2, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8938, 58, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8939, 58, 4, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8940, 58, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8941, 58, 1, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8942, 58, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8943, 58, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8944, 58, 4, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8945, 58, 5, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8946, 58, 1, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8947, 58, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8948, 58, 3, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8949, 58, 4, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8950, 58, 5, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8951, 59, 1, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8952, 59, 2, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8953, 59, 3, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8954, 59, 4, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8955, 59, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8956, 59, 1, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8957, 59, 2, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8958, 59, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8959, 59, 4, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8960, 59, 5, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8961, 59, 1, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8962, 59, 2, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8963, 59, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8964, 59, 4, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8965, 59, 5, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8966, 59, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8967, 59, 2, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8968, 59, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8969, 59, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8970, 59, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8971, 59, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8972, 59, 2, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8973, 59, 3, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8974, 59, 4, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8975, 59, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8976, 60, 1, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8977, 60, 2, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8978, 60, 3, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8979, 60, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8980, 60, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8981, 60, 1, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8982, 60, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8983, 60, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8984, 60, 4, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8985, 60, 5, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8986, 60, 1, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8987, 60, 2, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8988, 60, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8989, 60, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8990, 60, 5, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8991, 60, 1, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8992, 60, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8993, 60, 3, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8994, 60, 4, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8995, 60, 5, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8996, 60, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8997, 60, 2, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8998, 60, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (8999, 60, 4, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9000, 60, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9001, 61, 1, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9002, 61, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9003, 61, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9004, 61, 4, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9005, 61, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9006, 61, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9007, 61, 2, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9008, 61, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9009, 61, 4, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9010, 61, 5, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9011, 61, 1, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9012, 61, 2, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9013, 61, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9014, 61, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9015, 61, 5, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9016, 61, 1, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9017, 61, 2, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9018, 61, 3, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9019, 61, 4, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9020, 61, 5, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9021, 61, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9022, 61, 2, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9023, 61, 3, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9024, 61, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9025, 61, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9026, 62, 1, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9027, 62, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9028, 62, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9029, 62, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9030, 62, 5, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9031, 62, 1, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9032, 62, 2, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9033, 62, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9034, 62, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9035, 62, 5, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9036, 62, 1, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9037, 62, 2, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9038, 62, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9039, 62, 4, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9040, 62, 5, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9041, 62, 1, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9042, 62, 2, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9043, 62, 3, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9044, 62, 4, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9045, 62, 5, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9046, 62, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9047, 62, 2, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9048, 62, 3, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9049, 62, 4, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9050, 62, 5, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9051, 63, 1, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9052, 63, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9053, 63, 3, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9054, 63, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9055, 63, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9056, 63, 1, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9057, 63, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9058, 63, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9059, 63, 4, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9060, 63, 5, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9061, 63, 1, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9062, 63, 2, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9063, 63, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9064, 63, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9065, 63, 5, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9066, 63, 1, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9067, 63, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9068, 63, 3, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9069, 63, 4, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9070, 63, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9071, 63, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9072, 63, 2, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9073, 63, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9074, 63, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9075, 63, 5, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9076, 64, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9077, 64, 2, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9078, 64, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9079, 64, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9080, 64, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9081, 64, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9082, 64, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9083, 64, 3, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9084, 64, 4, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9085, 64, 5, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9086, 64, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9087, 64, 2, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9088, 64, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9089, 64, 4, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9090, 64, 5, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9091, 64, 1, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9092, 64, 2, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9093, 64, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9094, 64, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9095, 64, 5, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9096, 64, 1, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9097, 64, 2, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9098, 64, 3, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9099, 64, 4, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9100, 64, 5, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9101, 65, 1, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9102, 65, 2, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9103, 65, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9104, 65, 4, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9105, 65, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9106, 65, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9107, 65, 2, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9108, 65, 3, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9109, 65, 4, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9110, 65, 5, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9111, 65, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9112, 65, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9113, 65, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9114, 65, 4, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9115, 65, 5, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9116, 65, 1, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9117, 65, 2, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9118, 65, 3, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9119, 65, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9120, 65, 5, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9121, 65, 1, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9122, 65, 2, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9123, 65, 3, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9124, 65, 4, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9125, 65, 5, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9126, 66, 1, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9127, 66, 2, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9128, 66, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9129, 66, 4, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9130, 66, 5, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9131, 66, 1, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9132, 66, 2, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9133, 66, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9134, 66, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9135, 66, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9136, 66, 1, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9137, 66, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9138, 66, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9139, 66, 4, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9140, 66, 5, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9141, 66, 1, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9142, 66, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9143, 66, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9144, 66, 4, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9145, 66, 5, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9146, 66, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9147, 66, 2, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9148, 66, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9149, 66, 4, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9150, 66, 5, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9151, 67, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9152, 67, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9153, 67, 3, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9154, 67, 4, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9155, 67, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9156, 67, 1, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9157, 67, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9158, 67, 3, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9159, 67, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9160, 67, 5, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9161, 67, 1, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9162, 67, 2, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9163, 67, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9164, 67, 4, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9165, 67, 5, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9166, 67, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9167, 67, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9168, 67, 3, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9169, 67, 4, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9170, 67, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9171, 67, 1, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9172, 67, 2, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9173, 67, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9174, 67, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9175, 67, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9176, 68, 1, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9177, 68, 2, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9178, 68, 3, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9179, 68, 4, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9180, 68, 5, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9181, 68, 1, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9182, 68, 2, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9183, 68, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9184, 68, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9185, 68, 5, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9186, 68, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9187, 68, 2, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9188, 68, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9189, 68, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9190, 68, 5, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9191, 68, 1, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9192, 68, 2, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9193, 68, 3, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9194, 68, 4, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9195, 68, 5, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9196, 68, 1, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9197, 68, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9198, 68, 3, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9199, 68, 4, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9200, 68, 5, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9201, 69, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9202, 69, 2, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9203, 69, 3, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9204, 69, 4, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9205, 69, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9206, 69, 1, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9207, 69, 2, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9208, 69, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9209, 69, 4, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9210, 69, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9211, 69, 1, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9212, 69, 2, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9213, 69, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9214, 69, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9215, 69, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9216, 69, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9217, 69, 2, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9218, 69, 3, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9219, 69, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9220, 69, 5, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9221, 69, 1, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9222, 69, 2, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9223, 69, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9224, 69, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9225, 69, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9226, 70, 1, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9227, 70, 2, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9228, 70, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9229, 70, 4, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9230, 70, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9231, 70, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9232, 70, 2, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9233, 70, 3, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9234, 70, 4, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9235, 70, 5, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9236, 70, 1, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9237, 70, 2, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9238, 70, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9239, 70, 4, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9240, 70, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9241, 70, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9242, 70, 2, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9243, 70, 3, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9244, 70, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9245, 70, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9246, 70, 1, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9247, 70, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9248, 70, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9249, 70, 4, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9250, 70, 5, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9251, 71, 1, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9252, 71, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9253, 71, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9254, 71, 4, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9255, 71, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9256, 71, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9257, 71, 2, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9258, 71, 3, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9259, 71, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9260, 71, 5, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9261, 71, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9262, 71, 2, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9263, 71, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9264, 71, 4, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9265, 71, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9266, 71, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9267, 71, 2, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9268, 71, 3, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9269, 71, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9270, 71, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9271, 71, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9272, 71, 2, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9273, 71, 3, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9274, 71, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9275, 71, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9276, 72, 1, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9277, 72, 2, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9278, 72, 3, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9279, 72, 4, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9280, 72, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9281, 72, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9282, 72, 2, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9283, 72, 3, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9284, 72, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9285, 72, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9286, 72, 1, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9287, 72, 2, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9288, 72, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9289, 72, 4, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9290, 72, 5, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9291, 72, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9292, 72, 2, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9293, 72, 3, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9294, 72, 4, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9295, 72, 5, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9296, 72, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9297, 72, 2, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9298, 72, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9299, 72, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9300, 72, 5, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9301, 73, 1, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9302, 73, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9303, 73, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9304, 73, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9305, 73, 5, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9306, 73, 1, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9307, 73, 2, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9308, 73, 3, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9309, 73, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9310, 73, 5, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9311, 73, 1, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9312, 73, 2, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9313, 73, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9314, 73, 4, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9315, 73, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9316, 73, 1, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9317, 73, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9318, 73, 3, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9319, 73, 4, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9320, 73, 5, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9321, 73, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9322, 73, 2, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9323, 73, 3, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9324, 73, 4, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9325, 73, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9326, 74, 1, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9327, 74, 2, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9328, 74, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9329, 74, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9330, 74, 5, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9331, 74, 1, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9332, 74, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9333, 74, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9334, 74, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9335, 74, 5, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9336, 74, 1, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9337, 74, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9338, 74, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9339, 74, 4, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9340, 74, 5, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9341, 74, 1, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9342, 74, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9343, 74, 3, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9344, 74, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9345, 74, 5, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9346, 74, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9347, 74, 2, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9348, 74, 3, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9349, 74, 4, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9350, 74, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9351, 75, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9352, 75, 2, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9353, 75, 3, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9354, 75, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9355, 75, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9356, 75, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9357, 75, 2, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9358, 75, 3, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9359, 75, 4, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9360, 75, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9361, 75, 1, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9362, 75, 2, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9363, 75, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9364, 75, 4, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9365, 75, 5, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9366, 75, 1, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9367, 75, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9368, 75, 3, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9369, 75, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9370, 75, 5, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9371, 75, 1, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9372, 75, 2, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9373, 75, 3, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9374, 75, 4, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9375, 75, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9376, 76, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9377, 76, 2, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9378, 76, 3, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9379, 76, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9380, 76, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9381, 76, 1, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9382, 76, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9383, 76, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9384, 76, 4, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9385, 76, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9386, 76, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9387, 76, 2, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9388, 76, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9389, 76, 4, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9390, 76, 5, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9391, 76, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9392, 76, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9393, 76, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9394, 76, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9395, 76, 5, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9396, 76, 1, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9397, 76, 2, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9398, 76, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9399, 76, 4, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9400, 76, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9401, 77, 1, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9402, 77, 2, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9403, 77, 3, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9404, 77, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9405, 77, 5, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9406, 77, 1, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9407, 77, 2, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9408, 77, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9409, 77, 4, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9410, 77, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9411, 77, 1, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9412, 77, 2, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9413, 77, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9414, 77, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9415, 77, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9416, 77, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9417, 77, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9418, 77, 3, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9419, 77, 4, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9420, 77, 5, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9421, 77, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9422, 77, 2, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9423, 77, 3, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9424, 77, 4, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9425, 77, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9426, 78, 1, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9427, 78, 2, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9428, 78, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9429, 78, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9430, 78, 5, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9431, 78, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9432, 78, 2, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9433, 78, 3, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9434, 78, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9435, 78, 5, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9436, 78, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9437, 78, 2, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9438, 78, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9439, 78, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9440, 78, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9441, 78, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9442, 78, 2, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9443, 78, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9444, 78, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9445, 78, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9446, 78, 1, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9447, 78, 2, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9448, 78, 3, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9449, 78, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9450, 78, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9451, 79, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9452, 79, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9453, 79, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9454, 79, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9455, 79, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9456, 79, 1, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9457, 79, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9458, 79, 3, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9459, 79, 4, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9460, 79, 5, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9461, 79, 1, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9462, 79, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9463, 79, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9464, 79, 4, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9465, 79, 5, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9466, 79, 1, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9467, 79, 2, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9468, 79, 3, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9469, 79, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9470, 79, 5, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9471, 79, 1, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9472, 79, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9473, 79, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9474, 79, 4, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9475, 79, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9476, 80, 1, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9477, 80, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9478, 80, 3, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9479, 80, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9480, 80, 5, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9481, 80, 1, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9482, 80, 2, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9483, 80, 3, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9484, 80, 4, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9485, 80, 5, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9486, 80, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9487, 80, 2, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9488, 80, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9489, 80, 4, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9490, 80, 5, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9491, 80, 1, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9492, 80, 2, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9493, 80, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9494, 80, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9495, 80, 5, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9496, 80, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9497, 80, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9498, 80, 3, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9499, 80, 4, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9500, 80, 5, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9501, 81, 1, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9502, 81, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9503, 81, 3, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9504, 81, 4, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9505, 81, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9506, 81, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9507, 81, 2, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9508, 81, 3, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9509, 81, 4, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9510, 81, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9511, 81, 1, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9512, 81, 2, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9513, 81, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9514, 81, 4, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9515, 81, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9516, 81, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9517, 81, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9518, 81, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9519, 81, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9520, 81, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9521, 81, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9522, 81, 2, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9523, 81, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9524, 81, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9525, 81, 5, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9526, 82, 1, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9527, 82, 2, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9528, 82, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9529, 82, 4, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9530, 82, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9531, 82, 1, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9532, 82, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9533, 82, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9534, 82, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9535, 82, 5, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9536, 82, 1, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9537, 82, 2, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9538, 82, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9539, 82, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9540, 82, 5, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9541, 82, 1, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9542, 82, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9543, 82, 3, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9544, 82, 4, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9545, 82, 5, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9546, 82, 1, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9547, 82, 2, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9548, 82, 3, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9549, 82, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9550, 82, 5, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9551, 83, 1, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9552, 83, 2, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9553, 83, 3, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9554, 83, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9555, 83, 5, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9556, 83, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9557, 83, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9558, 83, 3, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9559, 83, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9560, 83, 5, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9561, 83, 1, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9562, 83, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9563, 83, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9564, 83, 4, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9565, 83, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9566, 83, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9567, 83, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9568, 83, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9569, 83, 4, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9570, 83, 5, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9571, 83, 1, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9572, 83, 2, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9573, 83, 3, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9574, 83, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9575, 83, 5, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9576, 84, 1, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9577, 84, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9578, 84, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9579, 84, 4, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9580, 84, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9581, 84, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9582, 84, 2, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9583, 84, 3, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9584, 84, 4, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9585, 84, 5, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9586, 84, 1, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9587, 84, 2, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9588, 84, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9589, 84, 4, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9590, 84, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9591, 84, 1, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9592, 84, 2, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9593, 84, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9594, 84, 4, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9595, 84, 5, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9596, 84, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9597, 84, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9598, 84, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9599, 84, 4, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9600, 84, 5, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9601, 85, 1, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9602, 85, 2, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9603, 85, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9604, 85, 4, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9605, 85, 5, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9606, 85, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9607, 85, 2, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9608, 85, 3, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9609, 85, 4, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9610, 85, 5, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9611, 85, 1, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9612, 85, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9613, 85, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9614, 85, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9615, 85, 5, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9616, 85, 1, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9617, 85, 2, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9618, 85, 3, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9619, 85, 4, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9620, 85, 5, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9621, 85, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9622, 85, 2, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9623, 85, 3, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9624, 85, 4, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9625, 85, 5, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9626, 86, 1, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9627, 86, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9628, 86, 3, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9629, 86, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9630, 86, 5, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9631, 86, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9632, 86, 2, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9633, 86, 3, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9634, 86, 4, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9635, 86, 5, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9636, 86, 1, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9637, 86, 2, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9638, 86, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9639, 86, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9640, 86, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9641, 86, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9642, 86, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9643, 86, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9644, 86, 4, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9645, 86, 5, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9646, 86, 1, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9647, 86, 2, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9648, 86, 3, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9649, 86, 4, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9650, 86, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9651, 87, 1, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9652, 87, 2, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9653, 87, 3, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9654, 87, 4, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9655, 87, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9656, 87, 1, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9657, 87, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9658, 87, 3, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9659, 87, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9660, 87, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9661, 87, 1, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9662, 87, 2, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9663, 87, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9664, 87, 4, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9665, 87, 5, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9666, 87, 1, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9667, 87, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9668, 87, 3, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9669, 87, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9670, 87, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9671, 87, 1, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9672, 87, 2, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9673, 87, 3, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9674, 87, 4, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9675, 87, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9676, 88, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9677, 88, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9678, 88, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9679, 88, 4, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9680, 88, 5, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9681, 88, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9682, 88, 2, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9683, 88, 3, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9684, 88, 4, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9685, 88, 5, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9686, 88, 1, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9687, 88, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9688, 88, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9689, 88, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9690, 88, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9691, 88, 1, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9692, 88, 2, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9693, 88, 3, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9694, 88, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9695, 88, 5, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9696, 88, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9697, 88, 2, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9698, 88, 3, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9699, 88, 4, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9700, 88, 5, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9701, 89, 1, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9702, 89, 2, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9703, 89, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9704, 89, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9705, 89, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9706, 89, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9707, 89, 2, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9708, 89, 3, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9709, 89, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9710, 89, 5, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9711, 89, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9712, 89, 2, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9713, 89, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9714, 89, 4, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9715, 89, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9716, 89, 1, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9717, 89, 2, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9718, 89, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9719, 89, 4, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9720, 89, 5, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9721, 89, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9722, 89, 2, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9723, 89, 3, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9724, 89, 4, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9725, 89, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9726, 90, 1, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9727, 90, 2, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9728, 90, 3, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9729, 90, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9730, 90, 5, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9731, 90, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9732, 90, 2, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9733, 90, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9734, 90, 4, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9735, 90, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9736, 90, 1, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9737, 90, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9738, 90, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9739, 90, 4, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9740, 90, 5, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9741, 90, 1, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9742, 90, 2, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9743, 90, 3, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9744, 90, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9745, 90, 5, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9746, 90, 1, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9747, 90, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9748, 90, 3, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9749, 90, 4, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9750, 90, 5, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9751, 91, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9752, 91, 2, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9753, 91, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9754, 91, 4, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9755, 91, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9756, 91, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9757, 91, 2, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9758, 91, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9759, 91, 4, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9760, 91, 5, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9761, 91, 1, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9762, 91, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9763, 91, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9764, 91, 4, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9765, 91, 5, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9766, 91, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9767, 91, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9768, 91, 3, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9769, 91, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9770, 91, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9771, 91, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9772, 91, 2, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9773, 91, 3, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9774, 91, 4, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9775, 91, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9776, 92, 1, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9777, 92, 2, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9778, 92, 3, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9779, 92, 4, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9780, 92, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9781, 92, 1, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9782, 92, 2, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9783, 92, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9784, 92, 4, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9785, 92, 5, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9786, 92, 1, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9787, 92, 2, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9788, 92, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9789, 92, 4, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9790, 92, 5, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9791, 92, 1, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9792, 92, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9793, 92, 3, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9794, 92, 4, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9795, 92, 5, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9796, 92, 1, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9797, 92, 2, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9798, 92, 3, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9799, 92, 4, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9800, 92, 5, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9801, 93, 1, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9802, 93, 2, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9803, 93, 3, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9804, 93, 4, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9805, 93, 5, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9806, 93, 1, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9807, 93, 2, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9808, 93, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9809, 93, 4, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9810, 93, 5, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9811, 93, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9812, 93, 2, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9813, 93, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9814, 93, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9815, 93, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9816, 93, 1, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9817, 93, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9818, 93, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9819, 93, 4, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9820, 93, 5, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9821, 93, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9822, 93, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9823, 93, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9824, 93, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9825, 93, 5, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9826, 94, 1, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9827, 94, 2, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9828, 94, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9829, 94, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9830, 94, 5, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9831, 94, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9832, 94, 2, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9833, 94, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9834, 94, 4, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9835, 94, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9836, 94, 1, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9837, 94, 2, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9838, 94, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9839, 94, 4, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9840, 94, 5, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9841, 94, 1, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9842, 94, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9843, 94, 3, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9844, 94, 4, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9845, 94, 5, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9846, 94, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9847, 94, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9848, 94, 3, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9849, 94, 4, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9850, 94, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9851, 95, 1, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9852, 95, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9853, 95, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9854, 95, 4, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9855, 95, 5, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9856, 95, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9857, 95, 2, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9858, 95, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9859, 95, 4, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9860, 95, 5, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9861, 95, 1, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9862, 95, 2, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9863, 95, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9864, 95, 4, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9865, 95, 5, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9866, 95, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9867, 95, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9868, 95, 3, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9869, 95, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9870, 95, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9871, 95, 1, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9872, 95, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9873, 95, 3, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9874, 95, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9875, 95, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9876, 96, 1, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9877, 96, 2, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9878, 96, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9879, 96, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9880, 96, 5, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9881, 96, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9882, 96, 2, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9883, 96, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9884, 96, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9885, 96, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9886, 96, 1, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9887, 96, 2, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9888, 96, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9889, 96, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9890, 96, 5, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9891, 96, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9892, 96, 2, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9893, 96, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9894, 96, 4, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9895, 96, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9896, 96, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9897, 96, 2, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9898, 96, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9899, 96, 4, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9900, 96, 5, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9901, 97, 1, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9902, 97, 2, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9903, 97, 3, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9904, 97, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9905, 97, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9906, 97, 1, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9907, 97, 2, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9908, 97, 3, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9909, 97, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9910, 97, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9911, 97, 1, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9912, 97, 2, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9913, 97, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9914, 97, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9915, 97, 5, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9916, 97, 1, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9917, 97, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9918, 97, 3, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9919, 97, 4, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9920, 97, 5, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9921, 97, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9922, 97, 2, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9923, 97, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9924, 97, 4, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9925, 97, 5, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9926, 98, 1, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9927, 98, 2, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9928, 98, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9929, 98, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9930, 98, 5, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9931, 98, 1, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9932, 98, 2, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9933, 98, 3, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9934, 98, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9935, 98, 5, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9936, 98, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9937, 98, 2, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9938, 98, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9939, 98, 4, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9940, 98, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9941, 98, 1, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9942, 98, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9943, 98, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9944, 98, 4, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9945, 98, 5, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9946, 98, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9947, 98, 2, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9948, 98, 3, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9949, 98, 4, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9950, 98, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9951, 99, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9952, 99, 2, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9953, 99, 3, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9954, 99, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9955, 99, 5, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9956, 99, 1, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9957, 99, 2, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9958, 99, 3, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9959, 99, 4, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9960, 99, 5, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9961, 99, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9962, 99, 2, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9963, 99, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9964, 99, 4, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9965, 99, 5, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9966, 99, 1, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9967, 99, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9968, 99, 3, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9969, 99, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9970, 99, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9971, 99, 1, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9972, 99, 2, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9973, 99, 3, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9974, 99, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9975, 99, 5, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9976, 100, 1, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9977, 100, 2, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9978, 100, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9979, 100, 4, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9980, 100, 5, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9981, 100, 1, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9982, 100, 2, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9983, 100, 3, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9984, 100, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9985, 100, 5, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9986, 100, 1, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9987, 100, 2, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9988, 100, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9989, 100, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9990, 100, 5, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9991, 100, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9992, 100, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9993, 100, 3, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9994, 100, 4, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9995, 100, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9996, 100, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9997, 100, 2, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9998, 100, 3, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (9999, 100, 4, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10000, 100, 5, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10001, 101, 1, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10002, 101, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10003, 101, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10004, 101, 4, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10005, 101, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10006, 101, 1, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10007, 101, 2, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10008, 101, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10009, 101, 4, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10010, 101, 5, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10011, 101, 1, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10012, 101, 2, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10013, 101, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10014, 101, 4, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10015, 101, 5, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10016, 101, 1, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10017, 101, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10018, 101, 3, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10019, 101, 4, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10020, 101, 5, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10021, 101, 1, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10022, 101, 2, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10023, 101, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10024, 101, 4, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10025, 101, 5, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10026, 102, 1, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10027, 102, 2, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10028, 102, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10029, 102, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10030, 102, 5, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10031, 102, 1, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10032, 102, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10033, 102, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10034, 102, 4, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10035, 102, 5, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10036, 102, 1, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10037, 102, 2, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10038, 102, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10039, 102, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10040, 102, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10041, 102, 1, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10042, 102, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10043, 102, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10044, 102, 4, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10045, 102, 5, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10046, 102, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10047, 102, 2, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10048, 102, 3, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10049, 102, 4, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10050, 102, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10051, 103, 1, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10052, 103, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10053, 103, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10054, 103, 4, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10055, 103, 5, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10056, 103, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10057, 103, 2, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10058, 103, 3, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10059, 103, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10060, 103, 5, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10061, 103, 1, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10062, 103, 2, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10063, 103, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10064, 103, 4, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10065, 103, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10066, 103, 1, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10067, 103, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10068, 103, 3, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10069, 103, 4, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10070, 103, 5, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10071, 103, 1, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10072, 103, 2, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10073, 103, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10074, 103, 4, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10075, 103, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10076, 104, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10077, 104, 2, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10078, 104, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10079, 104, 4, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10080, 104, 5, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10081, 104, 1, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10082, 104, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10083, 104, 3, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10084, 104, 4, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10085, 104, 5, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10086, 104, 1, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10087, 104, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10088, 104, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10089, 104, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10090, 104, 5, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10091, 104, 1, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10092, 104, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10093, 104, 3, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10094, 104, 4, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10095, 104, 5, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10096, 104, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10097, 104, 2, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10098, 104, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10099, 104, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10100, 104, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10101, 105, 1, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10102, 105, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10103, 105, 3, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10104, 105, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10105, 105, 5, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10106, 105, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10107, 105, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10108, 105, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10109, 105, 4, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10110, 105, 5, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10111, 105, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10112, 105, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10113, 105, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10114, 105, 4, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10115, 105, 5, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10116, 105, 1, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10117, 105, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10118, 105, 3, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10119, 105, 4, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10120, 105, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10121, 105, 1, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10122, 105, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10123, 105, 3, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10124, 105, 4, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10125, 105, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10126, 106, 1, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10127, 106, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10128, 106, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10129, 106, 4, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10130, 106, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10131, 106, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10132, 106, 2, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10133, 106, 3, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10134, 106, 4, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10135, 106, 5, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10136, 106, 1, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10137, 106, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10138, 106, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10139, 106, 4, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10140, 106, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10141, 106, 1, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10142, 106, 2, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10143, 106, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10144, 106, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10145, 106, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10146, 106, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10147, 106, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10148, 106, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10149, 106, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10150, 106, 5, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10151, 107, 1, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10152, 107, 2, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10153, 107, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10154, 107, 4, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10155, 107, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10156, 107, 1, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10157, 107, 2, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10158, 107, 3, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10159, 107, 4, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10160, 107, 5, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10161, 107, 1, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10162, 107, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10163, 107, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10164, 107, 4, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10165, 107, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10166, 107, 1, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10167, 107, 2, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10168, 107, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10169, 107, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10170, 107, 5, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10171, 107, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10172, 107, 2, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10173, 107, 3, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10174, 107, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10175, 107, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10176, 108, 1, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10177, 108, 2, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10178, 108, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10179, 108, 4, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10180, 108, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10181, 108, 1, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10182, 108, 2, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10183, 108, 3, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10184, 108, 4, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10185, 108, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10186, 108, 1, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10187, 108, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10188, 108, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10189, 108, 4, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10190, 108, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10191, 108, 1, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10192, 108, 2, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10193, 108, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10194, 108, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10195, 108, 5, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10196, 108, 1, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10197, 108, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10198, 108, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10199, 108, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10200, 108, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10201, 109, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10202, 109, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10203, 109, 3, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10204, 109, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10205, 109, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10206, 109, 1, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10207, 109, 2, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10208, 109, 3, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10209, 109, 4, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10210, 109, 5, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10211, 109, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10212, 109, 2, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10213, 109, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10214, 109, 4, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10215, 109, 5, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10216, 109, 1, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10217, 109, 2, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10218, 109, 3, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10219, 109, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10220, 109, 5, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10221, 109, 1, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10222, 109, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10223, 109, 3, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10224, 109, 4, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10225, 109, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10226, 110, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10227, 110, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10228, 110, 3, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10229, 110, 4, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10230, 110, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10231, 110, 1, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10232, 110, 2, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10233, 110, 3, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10234, 110, 4, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10235, 110, 5, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10236, 110, 1, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10237, 110, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10238, 110, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10239, 110, 4, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10240, 110, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10241, 110, 1, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10242, 110, 2, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10243, 110, 3, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10244, 110, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10245, 110, 5, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10246, 110, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10247, 110, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10248, 110, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10249, 110, 4, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10250, 110, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10251, 111, 1, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10252, 111, 2, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10253, 111, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10254, 111, 4, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10255, 111, 5, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10256, 111, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10257, 111, 2, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10258, 111, 3, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10259, 111, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10260, 111, 5, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10261, 111, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10262, 111, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10263, 111, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10264, 111, 4, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10265, 111, 5, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10266, 111, 1, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10267, 111, 2, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10268, 111, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10269, 111, 4, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10270, 111, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10271, 111, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10272, 111, 2, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10273, 111, 3, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10274, 111, 4, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10275, 111, 5, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10276, 112, 1, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10277, 112, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10278, 112, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10279, 112, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10280, 112, 5, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10281, 112, 1, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10282, 112, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10283, 112, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10284, 112, 4, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10285, 112, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10286, 112, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10287, 112, 2, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10288, 112, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10289, 112, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10290, 112, 5, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10291, 112, 1, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10292, 112, 2, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10293, 112, 3, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10294, 112, 4, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10295, 112, 5, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10296, 112, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10297, 112, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10298, 112, 3, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10299, 112, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10300, 112, 5, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10301, 113, 1, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10302, 113, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10303, 113, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10304, 113, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10305, 113, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10306, 113, 1, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10307, 113, 2, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10308, 113, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10309, 113, 4, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10310, 113, 5, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10311, 113, 1, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10312, 113, 2, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10313, 113, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10314, 113, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10315, 113, 5, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10316, 113, 1, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10317, 113, 2, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10318, 113, 3, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10319, 113, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10320, 113, 5, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10321, 113, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10322, 113, 2, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10323, 113, 3, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10324, 113, 4, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10325, 113, 5, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10326, 114, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10327, 114, 2, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10328, 114, 3, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10329, 114, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10330, 114, 5, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10331, 114, 1, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10332, 114, 2, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10333, 114, 3, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10334, 114, 4, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10335, 114, 5, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10336, 114, 1, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10337, 114, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10338, 114, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10339, 114, 4, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10340, 114, 5, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10341, 114, 1, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10342, 114, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10343, 114, 3, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10344, 114, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10345, 114, 5, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10346, 114, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10347, 114, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10348, 114, 3, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10349, 114, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10350, 114, 5, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10351, 115, 1, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10352, 115, 2, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10353, 115, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10354, 115, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10355, 115, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10356, 115, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10357, 115, 2, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10358, 115, 3, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10359, 115, 4, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10360, 115, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10361, 115, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10362, 115, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10363, 115, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10364, 115, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10365, 115, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10366, 115, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10367, 115, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10368, 115, 3, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10369, 115, 4, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10370, 115, 5, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10371, 115, 1, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10372, 115, 2, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10373, 115, 3, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10374, 115, 4, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10375, 115, 5, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10376, 116, 1, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10377, 116, 2, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10378, 116, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10379, 116, 4, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10380, 116, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10381, 116, 1, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10382, 116, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10383, 116, 3, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10384, 116, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10385, 116, 5, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10386, 116, 1, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10387, 116, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10388, 116, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10389, 116, 4, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10390, 116, 5, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10391, 116, 1, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10392, 116, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10393, 116, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10394, 116, 4, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10395, 116, 5, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10396, 116, 1, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10397, 116, 2, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10398, 116, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10399, 116, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10400, 116, 5, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10401, 117, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10402, 117, 2, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10403, 117, 3, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10404, 117, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10405, 117, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10406, 117, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10407, 117, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10408, 117, 3, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10409, 117, 4, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10410, 117, 5, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10411, 117, 1, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10412, 117, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10413, 117, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10414, 117, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10415, 117, 5, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10416, 117, 1, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10417, 117, 2, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10418, 117, 3, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10419, 117, 4, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10420, 117, 5, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10421, 117, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10422, 117, 2, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10423, 117, 3, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10424, 117, 4, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10425, 117, 5, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10426, 118, 1, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10427, 118, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10428, 118, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10429, 118, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10430, 118, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10431, 118, 1, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10432, 118, 2, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10433, 118, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10434, 118, 4, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10435, 118, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10436, 118, 1, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10437, 118, 2, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10438, 118, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10439, 118, 4, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10440, 118, 5, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10441, 118, 1, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10442, 118, 2, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10443, 118, 3, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10444, 118, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10445, 118, 5, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10446, 118, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10447, 118, 2, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10448, 118, 3, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10449, 118, 4, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10450, 118, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10451, 119, 1, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10452, 119, 2, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10453, 119, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10454, 119, 4, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10455, 119, 5, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10456, 119, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10457, 119, 2, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10458, 119, 3, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10459, 119, 4, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10460, 119, 5, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10461, 119, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10462, 119, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10463, 119, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10464, 119, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10465, 119, 5, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10466, 119, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10467, 119, 2, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10468, 119, 3, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10469, 119, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10470, 119, 5, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10471, 119, 1, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10472, 119, 2, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10473, 119, 3, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10474, 119, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10475, 119, 5, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10476, 120, 1, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10477, 120, 2, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10478, 120, 3, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10479, 120, 4, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10480, 120, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10481, 120, 1, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10482, 120, 2, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10483, 120, 3, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10484, 120, 4, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10485, 120, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10486, 120, 1, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10487, 120, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10488, 120, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10489, 120, 4, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10490, 120, 5, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10491, 120, 1, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10492, 120, 2, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10493, 120, 3, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10494, 120, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10495, 120, 5, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10496, 120, 1, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10497, 120, 2, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10498, 120, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10499, 120, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10500, 120, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10501, 121, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10502, 121, 2, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10503, 121, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10504, 121, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10505, 121, 5, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10506, 121, 1, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10507, 121, 2, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10508, 121, 3, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10509, 121, 4, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10510, 121, 5, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10511, 121, 1, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10512, 121, 2, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10513, 121, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10514, 121, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10515, 121, 5, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10516, 121, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10517, 121, 2, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10518, 121, 3, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10519, 121, 4, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10520, 121, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10521, 121, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10522, 121, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10523, 121, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10524, 121, 4, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10525, 121, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10526, 122, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10527, 122, 2, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10528, 122, 3, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10529, 122, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10530, 122, 5, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10531, 122, 1, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10532, 122, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10533, 122, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10534, 122, 4, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10535, 122, 5, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10536, 122, 1, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10537, 122, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10538, 122, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10539, 122, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10540, 122, 5, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10541, 122, 1, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10542, 122, 2, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10543, 122, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10544, 122, 4, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10545, 122, 5, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10546, 122, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10547, 122, 2, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10548, 122, 3, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10549, 122, 4, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10550, 122, 5, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10551, 123, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10552, 123, 2, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10553, 123, 3, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10554, 123, 4, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10555, 123, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10556, 123, 1, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10557, 123, 2, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10558, 123, 3, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10559, 123, 4, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10560, 123, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10561, 123, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10562, 123, 2, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10563, 123, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10564, 123, 4, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10565, 123, 5, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10566, 123, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10567, 123, 2, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10568, 123, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10569, 123, 4, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10570, 123, 5, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10571, 123, 1, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10572, 123, 2, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10573, 123, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10574, 123, 4, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10575, 123, 5, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10576, 124, 1, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10577, 124, 2, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10578, 124, 3, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10579, 124, 4, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10580, 124, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10581, 124, 1, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10582, 124, 2, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10583, 124, 3, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10584, 124, 4, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10585, 124, 5, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10586, 124, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10587, 124, 2, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10588, 124, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10589, 124, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10590, 124, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10591, 124, 1, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10592, 124, 2, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10593, 124, 3, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10594, 124, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10595, 124, 5, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10596, 124, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10597, 124, 2, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10598, 124, 3, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10599, 124, 4, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10600, 124, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10601, 125, 1, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10602, 125, 2, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10603, 125, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10604, 125, 4, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10605, 125, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10606, 125, 1, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10607, 125, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10608, 125, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10609, 125, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10610, 125, 5, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10611, 125, 1, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10612, 125, 2, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10613, 125, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10614, 125, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10615, 125, 5, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10616, 125, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10617, 125, 2, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10618, 125, 3, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10619, 125, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10620, 125, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10621, 125, 1, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10622, 125, 2, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10623, 125, 3, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10624, 125, 4, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10625, 125, 5, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10626, 126, 1, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10627, 126, 2, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10628, 126, 3, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10629, 126, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10630, 126, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10631, 126, 1, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10632, 126, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10633, 126, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10634, 126, 4, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10635, 126, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10636, 126, 1, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10637, 126, 2, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10638, 126, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10639, 126, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10640, 126, 5, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10641, 126, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10642, 126, 2, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10643, 126, 3, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10644, 126, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10645, 126, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10646, 126, 1, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10647, 126, 2, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10648, 126, 3, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10649, 126, 4, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10650, 126, 5, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10651, 127, 1, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10652, 127, 2, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10653, 127, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10654, 127, 4, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10655, 127, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10656, 127, 1, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10657, 127, 2, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10658, 127, 3, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10659, 127, 4, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10660, 127, 5, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10661, 127, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10662, 127, 2, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10663, 127, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10664, 127, 4, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10665, 127, 5, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10666, 127, 1, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10667, 127, 2, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10668, 127, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10669, 127, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10670, 127, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10671, 127, 1, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10672, 127, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10673, 127, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10674, 127, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10675, 127, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10676, 128, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10677, 128, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10678, 128, 3, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10679, 128, 4, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10680, 128, 5, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10681, 128, 1, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10682, 128, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10683, 128, 3, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10684, 128, 4, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10685, 128, 5, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10686, 128, 1, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10687, 128, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10688, 128, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10689, 128, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10690, 128, 5, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10691, 128, 1, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10692, 128, 2, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10693, 128, 3, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10694, 128, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10695, 128, 5, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10696, 128, 1, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10697, 128, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10698, 128, 3, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10699, 128, 4, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10700, 128, 5, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10701, 129, 1, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10702, 129, 2, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10703, 129, 3, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10704, 129, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10705, 129, 5, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10706, 129, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10707, 129, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10708, 129, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10709, 129, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10710, 129, 5, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10711, 129, 1, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10712, 129, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10713, 129, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10714, 129, 4, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10715, 129, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10716, 129, 1, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10717, 129, 2, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10718, 129, 3, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10719, 129, 4, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10720, 129, 5, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10721, 129, 1, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10722, 129, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10723, 129, 3, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10724, 129, 4, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10725, 129, 5, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10726, 130, 1, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10727, 130, 2, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10728, 130, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10729, 130, 4, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10730, 130, 5, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10731, 130, 1, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10732, 130, 2, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10733, 130, 3, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10734, 130, 4, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10735, 130, 5, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10736, 130, 1, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10737, 130, 2, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10738, 130, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10739, 130, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10740, 130, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10741, 130, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10742, 130, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10743, 130, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10744, 130, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10745, 130, 5, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10746, 130, 1, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10747, 130, 2, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10748, 130, 3, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10749, 130, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10750, 130, 5, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10751, 131, 1, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10752, 131, 2, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10753, 131, 3, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10754, 131, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10755, 131, 5, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10756, 131, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10757, 131, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10758, 131, 3, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10759, 131, 4, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10760, 131, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10761, 131, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10762, 131, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10763, 131, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10764, 131, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10765, 131, 5, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10766, 131, 1, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10767, 131, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10768, 131, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10769, 131, 4, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10770, 131, 5, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10771, 131, 1, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10772, 131, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10773, 131, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10774, 131, 4, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10775, 131, 5, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10776, 132, 1, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10777, 132, 2, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10778, 132, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10779, 132, 4, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10780, 132, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10781, 132, 1, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10782, 132, 2, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10783, 132, 3, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10784, 132, 4, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10785, 132, 5, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10786, 132, 1, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10787, 132, 2, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10788, 132, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10789, 132, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10790, 132, 5, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10791, 132, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10792, 132, 2, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10793, 132, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10794, 132, 4, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10795, 132, 5, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10796, 132, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10797, 132, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10798, 132, 3, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10799, 132, 4, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10800, 132, 5, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10801, 133, 1, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10802, 133, 2, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10803, 133, 3, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10804, 133, 4, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10805, 133, 5, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10806, 133, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10807, 133, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10808, 133, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10809, 133, 4, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10810, 133, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10811, 133, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10812, 133, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10813, 133, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10814, 133, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10815, 133, 5, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10816, 133, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10817, 133, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10818, 133, 3, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10819, 133, 4, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10820, 133, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10821, 133, 1, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10822, 133, 2, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10823, 133, 3, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10824, 133, 4, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10825, 133, 5, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10826, 134, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10827, 134, 2, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10828, 134, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10829, 134, 4, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10830, 134, 5, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10831, 134, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10832, 134, 2, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10833, 134, 3, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10834, 134, 4, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10835, 134, 5, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10836, 134, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10837, 134, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10838, 134, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10839, 134, 4, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10840, 134, 5, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10841, 134, 1, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10842, 134, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10843, 134, 3, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10844, 134, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10845, 134, 5, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10846, 134, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10847, 134, 2, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10848, 134, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10849, 134, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10850, 134, 5, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10851, 135, 1, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10852, 135, 2, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10853, 135, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10854, 135, 4, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10855, 135, 5, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10856, 135, 1, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10857, 135, 2, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10858, 135, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10859, 135, 4, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10860, 135, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10861, 135, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10862, 135, 2, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10863, 135, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10864, 135, 4, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10865, 135, 5, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10866, 135, 1, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10867, 135, 2, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10868, 135, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10869, 135, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10870, 135, 5, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10871, 135, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10872, 135, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10873, 135, 3, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10874, 135, 4, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10875, 135, 5, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10876, 136, 1, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10877, 136, 2, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10878, 136, 3, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10879, 136, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10880, 136, 5, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10881, 136, 1, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10882, 136, 2, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10883, 136, 3, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10884, 136, 4, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10885, 136, 5, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10886, 136, 1, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10887, 136, 2, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10888, 136, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10889, 136, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10890, 136, 5, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10891, 136, 1, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10892, 136, 2, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10893, 136, 3, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10894, 136, 4, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10895, 136, 5, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10896, 136, 1, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10897, 136, 2, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10898, 136, 3, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10899, 136, 4, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10900, 136, 5, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10901, 137, 1, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10902, 137, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10903, 137, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10904, 137, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10905, 137, 5, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10906, 137, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10907, 137, 2, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10908, 137, 3, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10909, 137, 4, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10910, 137, 5, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10911, 137, 1, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10912, 137, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10913, 137, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10914, 137, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10915, 137, 5, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10916, 137, 1, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10917, 137, 2, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10918, 137, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10919, 137, 4, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10920, 137, 5, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10921, 137, 1, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10922, 137, 2, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10923, 137, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10924, 137, 4, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10925, 137, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10926, 138, 1, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10927, 138, 2, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10928, 138, 3, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10929, 138, 4, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10930, 138, 5, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10931, 138, 1, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10932, 138, 2, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10933, 138, 3, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10934, 138, 4, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10935, 138, 5, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10936, 138, 1, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10937, 138, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10938, 138, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10939, 138, 4, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10940, 138, 5, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10941, 138, 1, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10942, 138, 2, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10943, 138, 3, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10944, 138, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10945, 138, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10946, 138, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10947, 138, 2, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10948, 138, 3, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10949, 138, 4, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10950, 138, 5, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10951, 139, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10952, 139, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10953, 139, 3, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10954, 139, 4, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10955, 139, 5, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10956, 139, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10957, 139, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10958, 139, 3, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10959, 139, 4, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10960, 139, 5, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10961, 139, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10962, 139, 2, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10963, 139, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10964, 139, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10965, 139, 5, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10966, 139, 1, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10967, 139, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10968, 139, 3, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10969, 139, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10970, 139, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10971, 139, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10972, 139, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10973, 139, 3, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10974, 139, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10975, 139, 5, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10976, 140, 1, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10977, 140, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10978, 140, 3, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10979, 140, 4, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10980, 140, 5, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10981, 140, 1, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10982, 140, 2, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10983, 140, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10984, 140, 4, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10985, 140, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10986, 140, 1, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10987, 140, 2, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10988, 140, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10989, 140, 4, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10990, 140, 5, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10991, 140, 1, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10992, 140, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10993, 140, 3, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10994, 140, 4, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10995, 140, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10996, 140, 1, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10997, 140, 2, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10998, 140, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (10999, 140, 4, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11000, 140, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11001, 141, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11002, 141, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11003, 141, 3, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11004, 141, 4, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11005, 141, 5, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11006, 141, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11007, 141, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11008, 141, 3, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11009, 141, 4, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11010, 141, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11011, 141, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11012, 141, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11013, 141, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11014, 141, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11015, 141, 5, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11016, 141, 1, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11017, 141, 2, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11018, 141, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11019, 141, 4, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11020, 141, 5, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11021, 141, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11022, 141, 2, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11023, 141, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11024, 141, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11025, 141, 5, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11026, 142, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11027, 142, 2, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11028, 142, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11029, 142, 4, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11030, 142, 5, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11031, 142, 1, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11032, 142, 2, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11033, 142, 3, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11034, 142, 4, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11035, 142, 5, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11036, 142, 1, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11037, 142, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11038, 142, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11039, 142, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11040, 142, 5, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11041, 142, 1, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11042, 142, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11043, 142, 3, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11044, 142, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11045, 142, 5, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11046, 142, 1, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11047, 142, 2, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11048, 142, 3, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11049, 142, 4, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11050, 142, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11051, 143, 1, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11052, 143, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11053, 143, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11054, 143, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11055, 143, 5, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11056, 143, 1, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11057, 143, 2, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11058, 143, 3, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11059, 143, 4, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11060, 143, 5, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11061, 143, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11062, 143, 2, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11063, 143, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11064, 143, 4, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11065, 143, 5, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11066, 143, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11067, 143, 2, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11068, 143, 3, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11069, 143, 4, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11070, 143, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11071, 143, 1, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11072, 143, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11073, 143, 3, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11074, 143, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11075, 143, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11076, 144, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11077, 144, 2, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11078, 144, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11079, 144, 4, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11080, 144, 5, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11081, 144, 1, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11082, 144, 2, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11083, 144, 3, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11084, 144, 4, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11085, 144, 5, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11086, 144, 1, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11087, 144, 2, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11088, 144, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11089, 144, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11090, 144, 5, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11091, 144, 1, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11092, 144, 2, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11093, 144, 3, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11094, 144, 4, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11095, 144, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11096, 144, 1, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11097, 144, 2, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11098, 144, 3, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11099, 144, 4, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11100, 144, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11101, 145, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11102, 145, 2, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11103, 145, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11104, 145, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11105, 145, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11106, 145, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11107, 145, 2, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11108, 145, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11109, 145, 4, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11110, 145, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11111, 145, 1, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11112, 145, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11113, 145, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11114, 145, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11115, 145, 5, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11116, 145, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11117, 145, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11118, 145, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11119, 145, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11120, 145, 5, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11121, 145, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11122, 145, 2, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11123, 145, 3, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11124, 145, 4, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11125, 145, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11126, 146, 1, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11127, 146, 2, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11128, 146, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11129, 146, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11130, 146, 5, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11131, 146, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11132, 146, 2, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11133, 146, 3, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11134, 146, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11135, 146, 5, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11136, 146, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11137, 146, 2, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11138, 146, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11139, 146, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11140, 146, 5, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11141, 146, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11142, 146, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11143, 146, 3, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11144, 146, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11145, 146, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11146, 146, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11147, 146, 2, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11148, 146, 3, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11149, 146, 4, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11150, 146, 5, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11151, 147, 1, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11152, 147, 2, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11153, 147, 3, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11154, 147, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11155, 147, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11156, 147, 1, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11157, 147, 2, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11158, 147, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11159, 147, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11160, 147, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11161, 147, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11162, 147, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11163, 147, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11164, 147, 4, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11165, 147, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11166, 147, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11167, 147, 2, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11168, 147, 3, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11169, 147, 4, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11170, 147, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11171, 147, 1, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11172, 147, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11173, 147, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11174, 147, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11175, 147, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11176, 148, 1, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11177, 148, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11178, 148, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11179, 148, 4, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11180, 148, 5, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11181, 148, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11182, 148, 2, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11183, 148, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11184, 148, 4, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11185, 148, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11186, 148, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11187, 148, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11188, 148, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11189, 148, 4, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11190, 148, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11191, 148, 1, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11192, 148, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11193, 148, 3, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11194, 148, 4, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11195, 148, 5, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11196, 148, 1, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11197, 148, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11198, 148, 3, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11199, 148, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11200, 148, 5, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11201, 149, 1, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11202, 149, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11203, 149, 3, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11204, 149, 4, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11205, 149, 5, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11206, 149, 1, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11207, 149, 2, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11208, 149, 3, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11209, 149, 4, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11210, 149, 5, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11211, 149, 1, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11212, 149, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11213, 149, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11214, 149, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11215, 149, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11216, 149, 1, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11217, 149, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11218, 149, 3, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11219, 149, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11220, 149, 5, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11221, 149, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11222, 149, 2, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11223, 149, 3, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11224, 149, 4, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11225, 149, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11226, 150, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11227, 150, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11228, 150, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11229, 150, 4, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11230, 150, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11231, 150, 1, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11232, 150, 2, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11233, 150, 3, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11234, 150, 4, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11235, 150, 5, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11236, 150, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11237, 150, 2, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11238, 150, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11239, 150, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11240, 150, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11241, 150, 1, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11242, 150, 2, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11243, 150, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11244, 150, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11245, 150, 5, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11246, 150, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11247, 150, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11248, 150, 3, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11249, 150, 4, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11250, 150, 5, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11251, 151, 1, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11252, 151, 2, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11253, 151, 3, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11254, 151, 4, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11255, 151, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11256, 151, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11257, 151, 2, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11258, 151, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11259, 151, 4, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11260, 151, 5, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11261, 151, 1, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11262, 151, 2, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11263, 151, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11264, 151, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11265, 151, 5, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11266, 151, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11267, 151, 2, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11268, 151, 3, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11269, 151, 4, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11270, 151, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11271, 151, 1, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11272, 151, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11273, 151, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11274, 151, 4, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11275, 151, 5, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11276, 152, 1, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11277, 152, 2, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11278, 152, 3, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11279, 152, 4, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11280, 152, 5, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11281, 152, 1, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11282, 152, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11283, 152, 3, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11284, 152, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11285, 152, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11286, 152, 1, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11287, 152, 2, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11288, 152, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11289, 152, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11290, 152, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11291, 152, 1, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11292, 152, 2, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11293, 152, 3, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11294, 152, 4, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11295, 152, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11296, 152, 1, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11297, 152, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11298, 152, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11299, 152, 4, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11300, 152, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11301, 153, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11302, 153, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11303, 153, 3, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11304, 153, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11305, 153, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11306, 153, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11307, 153, 2, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11308, 153, 3, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11309, 153, 4, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11310, 153, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11311, 153, 1, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11312, 153, 2, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11313, 153, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11314, 153, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11315, 153, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11316, 153, 1, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11317, 153, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11318, 153, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11319, 153, 4, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11320, 153, 5, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11321, 153, 1, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11322, 153, 2, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11323, 153, 3, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11324, 153, 4, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11325, 153, 5, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11326, 154, 1, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11327, 154, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11328, 154, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11329, 154, 4, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11330, 154, 5, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11331, 154, 1, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11332, 154, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11333, 154, 3, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11334, 154, 4, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11335, 154, 5, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11336, 154, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11337, 154, 2, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11338, 154, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11339, 154, 4, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11340, 154, 5, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11341, 154, 1, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11342, 154, 2, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11343, 154, 3, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11344, 154, 4, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11345, 154, 5, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11346, 154, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11347, 154, 2, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11348, 154, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11349, 154, 4, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11350, 154, 5, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11351, 155, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11352, 155, 2, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11353, 155, 3, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11354, 155, 4, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11355, 155, 5, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11356, 155, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11357, 155, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11358, 155, 3, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11359, 155, 4, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11360, 155, 5, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11361, 155, 1, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11362, 155, 2, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11363, 155, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11364, 155, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11365, 155, 5, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11366, 155, 1, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11367, 155, 2, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11368, 155, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11369, 155, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11370, 155, 5, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11371, 155, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11372, 155, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11373, 155, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11374, 155, 4, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11375, 155, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11376, 156, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11377, 156, 2, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11378, 156, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11379, 156, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11380, 156, 5, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11381, 156, 1, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11382, 156, 2, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11383, 156, 3, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11384, 156, 4, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11385, 156, 5, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11386, 156, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11387, 156, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11388, 156, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11389, 156, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11390, 156, 5, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11391, 156, 1, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11392, 156, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11393, 156, 3, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11394, 156, 4, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11395, 156, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11396, 156, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11397, 156, 2, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11398, 156, 3, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11399, 156, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11400, 156, 5, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11401, 157, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11402, 157, 2, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11403, 157, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11404, 157, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11405, 157, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11406, 157, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11407, 157, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11408, 157, 3, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11409, 157, 4, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11410, 157, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11411, 157, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11412, 157, 2, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11413, 157, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11414, 157, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11415, 157, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11416, 157, 1, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11417, 157, 2, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11418, 157, 3, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11419, 157, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11420, 157, 5, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11421, 157, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11422, 157, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11423, 157, 3, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11424, 157, 4, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11425, 157, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11426, 158, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11427, 158, 2, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11428, 158, 3, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11429, 158, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11430, 158, 5, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11431, 158, 1, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11432, 158, 2, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11433, 158, 3, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11434, 158, 4, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11435, 158, 5, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11436, 158, 1, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11437, 158, 2, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11438, 158, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11439, 158, 4, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11440, 158, 5, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11441, 158, 1, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11442, 158, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11443, 158, 3, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11444, 158, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11445, 158, 5, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11446, 158, 1, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11447, 158, 2, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11448, 158, 3, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11449, 158, 4, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11450, 158, 5, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11451, 159, 1, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11452, 159, 2, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11453, 159, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11454, 159, 4, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11455, 159, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11456, 159, 1, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11457, 159, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11458, 159, 3, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11459, 159, 4, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11460, 159, 5, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11461, 159, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11462, 159, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11463, 159, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11464, 159, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11465, 159, 5, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11466, 159, 1, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11467, 159, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11468, 159, 3, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11469, 159, 4, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11470, 159, 5, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11471, 159, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11472, 159, 2, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11473, 159, 3, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11474, 159, 4, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11475, 159, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11476, 160, 1, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11477, 160, 2, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11478, 160, 3, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11479, 160, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11480, 160, 5, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11481, 160, 1, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11482, 160, 2, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11483, 160, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11484, 160, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11485, 160, 5, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11486, 160, 1, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11487, 160, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11488, 160, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11489, 160, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11490, 160, 5, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11491, 160, 1, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11492, 160, 2, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11493, 160, 3, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11494, 160, 4, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11495, 160, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11496, 160, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11497, 160, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11498, 160, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11499, 160, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11500, 160, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11501, 161, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11502, 161, 2, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11503, 161, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11504, 161, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11505, 161, 5, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11506, 161, 1, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11507, 161, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11508, 161, 3, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11509, 161, 4, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11510, 161, 5, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11511, 161, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11512, 161, 2, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11513, 161, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11514, 161, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11515, 161, 5, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11516, 161, 1, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11517, 161, 2, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11518, 161, 3, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11519, 161, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11520, 161, 5, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11521, 161, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11522, 161, 2, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11523, 161, 3, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11524, 161, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11525, 161, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11526, 162, 1, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11527, 162, 2, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11528, 162, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11529, 162, 4, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11530, 162, 5, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11531, 162, 1, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11532, 162, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11533, 162, 3, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11534, 162, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11535, 162, 5, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11536, 162, 1, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11537, 162, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11538, 162, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11539, 162, 4, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11540, 162, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11541, 162, 1, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11542, 162, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11543, 162, 3, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11544, 162, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11545, 162, 5, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11546, 162, 1, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11547, 162, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11548, 162, 3, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11549, 162, 4, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11550, 162, 5, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11551, 163, 1, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11552, 163, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11553, 163, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11554, 163, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11555, 163, 5, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11556, 163, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11557, 163, 2, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11558, 163, 3, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11559, 163, 4, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11560, 163, 5, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11561, 163, 1, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11562, 163, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11563, 163, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11564, 163, 4, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11565, 163, 5, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11566, 163, 1, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11567, 163, 2, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11568, 163, 3, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11569, 163, 4, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11570, 163, 5, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11571, 163, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11572, 163, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11573, 163, 3, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11574, 163, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11575, 163, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11576, 164, 1, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11577, 164, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11578, 164, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11579, 164, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11580, 164, 5, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11581, 164, 1, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11582, 164, 2, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11583, 164, 3, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11584, 164, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11585, 164, 5, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11586, 164, 1, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11587, 164, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11588, 164, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11589, 164, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11590, 164, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11591, 164, 1, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11592, 164, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11593, 164, 3, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11594, 164, 4, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11595, 164, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11596, 164, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11597, 164, 2, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11598, 164, 3, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11599, 164, 4, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11600, 164, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11601, 165, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11602, 165, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11603, 165, 3, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11604, 165, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11605, 165, 5, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11606, 165, 1, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11607, 165, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11608, 165, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11609, 165, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11610, 165, 5, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11611, 165, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11612, 165, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11613, 165, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11614, 165, 4, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11615, 165, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11616, 165, 1, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11617, 165, 2, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11618, 165, 3, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11619, 165, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11620, 165, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11621, 165, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11622, 165, 2, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11623, 165, 3, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11624, 165, 4, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11625, 165, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11626, 166, 1, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11627, 166, 2, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11628, 166, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11629, 166, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11630, 166, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11631, 166, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11632, 166, 2, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11633, 166, 3, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11634, 166, 4, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11635, 166, 5, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11636, 166, 1, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11637, 166, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11638, 166, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11639, 166, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11640, 166, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11641, 166, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11642, 166, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11643, 166, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11644, 166, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11645, 166, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11646, 166, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11647, 166, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11648, 166, 3, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11649, 166, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11650, 166, 5, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11651, 167, 1, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11652, 167, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11653, 167, 3, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11654, 167, 4, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11655, 167, 5, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11656, 167, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11657, 167, 2, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11658, 167, 3, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11659, 167, 4, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11660, 167, 5, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11661, 167, 1, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11662, 167, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11663, 167, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11664, 167, 4, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11665, 167, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11666, 167, 1, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11667, 167, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11668, 167, 3, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11669, 167, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11670, 167, 5, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11671, 167, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11672, 167, 2, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11673, 167, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11674, 167, 4, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11675, 167, 5, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11676, 168, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11677, 168, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11678, 168, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11679, 168, 4, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11680, 168, 5, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11681, 168, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11682, 168, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11683, 168, 3, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11684, 168, 4, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11685, 168, 5, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11686, 168, 1, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11687, 168, 2, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11688, 168, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11689, 168, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11690, 168, 5, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11691, 168, 1, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11692, 168, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11693, 168, 3, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11694, 168, 4, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11695, 168, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11696, 168, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11697, 168, 2, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11698, 168, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11699, 168, 4, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11700, 168, 5, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11701, 169, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11702, 169, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11703, 169, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11704, 169, 4, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11705, 169, 5, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11706, 169, 1, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11707, 169, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11708, 169, 3, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11709, 169, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11710, 169, 5, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11711, 169, 1, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11712, 169, 2, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11713, 169, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11714, 169, 4, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11715, 169, 5, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11716, 169, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11717, 169, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11718, 169, 3, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11719, 169, 4, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11720, 169, 5, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11721, 169, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11722, 169, 2, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11723, 169, 3, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11724, 169, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11725, 169, 5, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11726, 170, 1, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11727, 170, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11728, 170, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11729, 170, 4, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11730, 170, 5, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11731, 170, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11732, 170, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11733, 170, 3, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11734, 170, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11735, 170, 5, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11736, 170, 1, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11737, 170, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11738, 170, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11739, 170, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11740, 170, 5, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11741, 170, 1, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11742, 170, 2, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11743, 170, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11744, 170, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11745, 170, 5, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11746, 170, 1, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11747, 170, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11748, 170, 3, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11749, 170, 4, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11750, 170, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11751, 171, 1, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11752, 171, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11753, 171, 3, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11754, 171, 4, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11755, 171, 5, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11756, 171, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11757, 171, 2, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11758, 171, 3, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11759, 171, 4, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11760, 171, 5, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11761, 171, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11762, 171, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11763, 171, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11764, 171, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11765, 171, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11766, 171, 1, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11767, 171, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11768, 171, 3, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11769, 171, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11770, 171, 5, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11771, 171, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11772, 171, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11773, 171, 3, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11774, 171, 4, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11775, 171, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11776, 172, 1, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11777, 172, 2, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11778, 172, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11779, 172, 4, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11780, 172, 5, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11781, 172, 1, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11782, 172, 2, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11783, 172, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11784, 172, 4, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11785, 172, 5, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11786, 172, 1, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11787, 172, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11788, 172, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11789, 172, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11790, 172, 5, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11791, 172, 1, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11792, 172, 2, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11793, 172, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11794, 172, 4, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11795, 172, 5, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11796, 172, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11797, 172, 2, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11798, 172, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11799, 172, 4, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11800, 172, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11801, 173, 1, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11802, 173, 2, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11803, 173, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11804, 173, 4, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11805, 173, 5, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11806, 173, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11807, 173, 2, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11808, 173, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11809, 173, 4, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11810, 173, 5, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11811, 173, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11812, 173, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11813, 173, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11814, 173, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11815, 173, 5, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11816, 173, 1, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11817, 173, 2, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11818, 173, 3, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11819, 173, 4, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11820, 173, 5, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11821, 173, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11822, 173, 2, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11823, 173, 3, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11824, 173, 4, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11825, 173, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11826, 174, 1, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11827, 174, 2, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11828, 174, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11829, 174, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11830, 174, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11831, 174, 1, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11832, 174, 2, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11833, 174, 3, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11834, 174, 4, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11835, 174, 5, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11836, 174, 1, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11837, 174, 2, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11838, 174, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11839, 174, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11840, 174, 5, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11841, 174, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11842, 174, 2, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11843, 174, 3, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11844, 174, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11845, 174, 5, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11846, 174, 1, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11847, 174, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11848, 174, 3, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11849, 174, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11850, 174, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11851, 175, 1, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11852, 175, 2, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11853, 175, 3, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11854, 175, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11855, 175, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11856, 175, 1, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11857, 175, 2, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11858, 175, 3, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11859, 175, 4, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11860, 175, 5, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11861, 175, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11862, 175, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11863, 175, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11864, 175, 4, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11865, 175, 5, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11866, 175, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11867, 175, 2, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11868, 175, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11869, 175, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11870, 175, 5, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11871, 175, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11872, 175, 2, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11873, 175, 3, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11874, 175, 4, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11875, 175, 5, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11876, 176, 1, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11877, 176, 2, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11878, 176, 3, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11879, 176, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11880, 176, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11881, 176, 1, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11882, 176, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11883, 176, 3, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11884, 176, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11885, 176, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11886, 176, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11887, 176, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11888, 176, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11889, 176, 4, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11890, 176, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11891, 176, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11892, 176, 2, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11893, 176, 3, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11894, 176, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11895, 176, 5, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11896, 176, 1, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11897, 176, 2, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11898, 176, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11899, 176, 4, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11900, 176, 5, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11901, 177, 1, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11902, 177, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11903, 177, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11904, 177, 4, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11905, 177, 5, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11906, 177, 1, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11907, 177, 2, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11908, 177, 3, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11909, 177, 4, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11910, 177, 5, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11911, 177, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11912, 177, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11913, 177, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11914, 177, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11915, 177, 5, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11916, 177, 1, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11917, 177, 2, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11918, 177, 3, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11919, 177, 4, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11920, 177, 5, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11921, 177, 1, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11922, 177, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11923, 177, 3, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11924, 177, 4, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11925, 177, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11926, 178, 1, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11927, 178, 2, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11928, 178, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11929, 178, 4, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11930, 178, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11931, 178, 1, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11932, 178, 2, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11933, 178, 3, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11934, 178, 4, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11935, 178, 5, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11936, 178, 1, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11937, 178, 2, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11938, 178, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11939, 178, 4, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11940, 178, 5, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11941, 178, 1, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11942, 178, 2, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11943, 178, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11944, 178, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11945, 178, 5, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11946, 178, 1, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11947, 178, 2, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11948, 178, 3, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11949, 178, 4, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11950, 178, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11951, 179, 1, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11952, 179, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11953, 179, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11954, 179, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11955, 179, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11956, 179, 1, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11957, 179, 2, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11958, 179, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11959, 179, 4, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11960, 179, 5, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11961, 179, 1, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11962, 179, 2, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11963, 179, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11964, 179, 4, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11965, 179, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11966, 179, 1, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11967, 179, 2, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11968, 179, 3, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11969, 179, 4, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11970, 179, 5, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11971, 179, 1, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11972, 179, 2, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11973, 179, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11974, 179, 4, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11975, 179, 5, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11976, 180, 1, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11977, 180, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11978, 180, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11979, 180, 4, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11980, 180, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11981, 180, 1, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11982, 180, 2, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11983, 180, 3, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11984, 180, 4, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11985, 180, 5, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11986, 180, 1, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11987, 180, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11988, 180, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11989, 180, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11990, 180, 5, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11991, 180, 1, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11992, 180, 2, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11993, 180, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11994, 180, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11995, 180, 5, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11996, 180, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11997, 180, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11998, 180, 3, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (11999, 180, 4, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12000, 180, 5, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12001, 181, 1, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12002, 181, 2, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12003, 181, 3, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12004, 181, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12005, 181, 5, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12006, 181, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12007, 181, 2, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12008, 181, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12009, 181, 4, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12010, 181, 5, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12011, 181, 1, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12012, 181, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12013, 181, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12014, 181, 4, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12015, 181, 5, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12016, 181, 1, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12017, 181, 2, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12018, 181, 3, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12019, 181, 4, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12020, 181, 5, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12021, 181, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12022, 181, 2, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12023, 181, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12024, 181, 4, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12025, 181, 5, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12026, 182, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12027, 182, 2, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12028, 182, 3, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12029, 182, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12030, 182, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12031, 182, 1, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12032, 182, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12033, 182, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12034, 182, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12035, 182, 5, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12036, 182, 1, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12037, 182, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12038, 182, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12039, 182, 4, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12040, 182, 5, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12041, 182, 1, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12042, 182, 2, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12043, 182, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12044, 182, 4, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12045, 182, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12046, 182, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12047, 182, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12048, 182, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12049, 182, 4, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12050, 182, 5, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12051, 183, 1, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12052, 183, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12053, 183, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12054, 183, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12055, 183, 5, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12056, 183, 1, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12057, 183, 2, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12058, 183, 3, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12059, 183, 4, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12060, 183, 5, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12061, 183, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12062, 183, 2, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12063, 183, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12064, 183, 4, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12065, 183, 5, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12066, 183, 1, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12067, 183, 2, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12068, 183, 3, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12069, 183, 4, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12070, 183, 5, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12071, 183, 1, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12072, 183, 2, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12073, 183, 3, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12074, 183, 4, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12075, 183, 5, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12076, 184, 1, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12077, 184, 2, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12078, 184, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12079, 184, 4, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12080, 184, 5, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12081, 184, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12082, 184, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12083, 184, 3, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12084, 184, 4, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12085, 184, 5, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12086, 184, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12087, 184, 2, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12088, 184, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12089, 184, 4, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12090, 184, 5, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12091, 184, 1, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12092, 184, 2, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12093, 184, 3, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12094, 184, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12095, 184, 5, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12096, 184, 1, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12097, 184, 2, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12098, 184, 3, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12099, 184, 4, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12100, 184, 5, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12101, 185, 1, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12102, 185, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12103, 185, 3, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12104, 185, 4, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12105, 185, 5, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12106, 185, 1, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12107, 185, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12108, 185, 3, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12109, 185, 4, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12110, 185, 5, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12111, 185, 1, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12112, 185, 2, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12113, 185, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12114, 185, 4, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12115, 185, 5, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12116, 185, 1, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12117, 185, 2, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12118, 185, 3, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12119, 185, 4, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12120, 185, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12121, 185, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12122, 185, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12123, 185, 3, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12124, 185, 4, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12125, 185, 5, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12126, 186, 1, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12127, 186, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12128, 186, 3, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12129, 186, 4, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12130, 186, 5, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12131, 186, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12132, 186, 2, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12133, 186, 3, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12134, 186, 4, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12135, 186, 5, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12136, 186, 1, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12137, 186, 2, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12138, 186, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12139, 186, 4, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12140, 186, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12141, 186, 1, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12142, 186, 2, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12143, 186, 3, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12144, 186, 4, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12145, 186, 5, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12146, 186, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12147, 186, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12148, 186, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12149, 186, 4, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12150, 186, 5, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12151, 187, 1, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12152, 187, 2, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12153, 187, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12154, 187, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12155, 187, 5, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12156, 187, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12157, 187, 2, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12158, 187, 3, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12159, 187, 4, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12160, 187, 5, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12161, 187, 1, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12162, 187, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12163, 187, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12164, 187, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12165, 187, 5, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12166, 187, 1, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12167, 187, 2, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12168, 187, 3, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12169, 187, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12170, 187, 5, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12171, 187, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12172, 187, 2, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12173, 187, 3, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12174, 187, 4, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12175, 187, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12176, 188, 1, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12177, 188, 2, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12178, 188, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12179, 188, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12180, 188, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12181, 188, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12182, 188, 2, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12183, 188, 3, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12184, 188, 4, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12185, 188, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12186, 188, 1, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12187, 188, 2, 3, 42);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12188, 188, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12189, 188, 4, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12190, 188, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12191, 188, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12192, 188, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12193, 188, 3, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12194, 188, 4, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12195, 188, 5, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12196, 188, 1, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12197, 188, 2, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12198, 188, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12199, 188, 4, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12200, 188, 5, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12201, 189, 1, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12202, 189, 2, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12203, 189, 3, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12204, 189, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12205, 189, 5, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12206, 189, 1, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12207, 189, 2, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12208, 189, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12209, 189, 4, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12210, 189, 5, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12211, 189, 1, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12212, 189, 2, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12213, 189, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12214, 189, 4, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12215, 189, 5, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12216, 189, 1, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12217, 189, 2, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12218, 189, 3, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12219, 189, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12220, 189, 5, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12221, 189, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12222, 189, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12223, 189, 3, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12224, 189, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12225, 189, 5, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12226, 190, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12227, 190, 2, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12228, 190, 3, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12229, 190, 4, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12230, 190, 5, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12231, 190, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12232, 190, 2, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12233, 190, 3, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12234, 190, 4, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12235, 190, 5, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12236, 190, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12237, 190, 2, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12238, 190, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12239, 190, 4, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12240, 190, 5, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12241, 190, 1, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12242, 190, 2, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12243, 190, 3, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12244, 190, 4, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12245, 190, 5, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12246, 190, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12247, 190, 2, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12248, 190, 3, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12249, 190, 4, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12250, 190, 5, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12251, 191, 1, 1, 5);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12252, 191, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12253, 191, 3, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12254, 191, 4, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12255, 191, 5, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12256, 191, 1, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12257, 191, 2, 2, 30);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12258, 191, 3, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12259, 191, 4, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12260, 191, 5, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12261, 191, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12262, 191, 2, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12263, 191, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12264, 191, 4, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12265, 191, 5, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12266, 191, 1, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12267, 191, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12268, 191, 3, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12269, 191, 4, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12270, 191, 5, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12271, 191, 1, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12272, 191, 2, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12273, 191, 3, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12274, 191, 4, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12275, 191, 5, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12276, 192, 1, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12277, 192, 2, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12278, 192, 3, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12279, 192, 4, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12280, 192, 5, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12281, 192, 1, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12282, 192, 2, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12283, 192, 3, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12284, 192, 4, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12285, 192, 5, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12286, 192, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12287, 192, 2, 3, 40);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12288, 192, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12289, 192, 4, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12290, 192, 5, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12291, 192, 1, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12292, 192, 2, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12293, 192, 3, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12294, 192, 4, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12295, 192, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12296, 192, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12297, 192, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12298, 192, 3, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12299, 192, 4, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12300, 192, 5, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12301, 193, 1, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12302, 193, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12303, 193, 3, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12304, 193, 4, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12305, 193, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12306, 193, 1, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12307, 193, 2, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12308, 193, 3, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12309, 193, 4, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12310, 193, 5, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12311, 193, 1, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12312, 193, 2, 3, 44);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12313, 193, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12314, 193, 4, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12315, 193, 5, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12316, 193, 1, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12317, 193, 2, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12318, 193, 3, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12319, 193, 4, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12320, 193, 5, 4, 49);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12321, 193, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12322, 193, 2, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12323, 193, 3, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12324, 193, 4, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12325, 193, 5, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12326, 194, 1, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12327, 194, 2, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12328, 194, 3, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12329, 194, 4, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12330, 194, 5, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12331, 194, 1, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12332, 194, 2, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12333, 194, 3, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12334, 194, 4, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12335, 194, 5, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12336, 194, 1, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12337, 194, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12338, 194, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12339, 194, 4, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12340, 194, 5, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12341, 194, 1, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12342, 194, 2, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12343, 194, 3, 4, 46);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12344, 194, 4, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12345, 194, 5, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12346, 194, 1, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12347, 194, 2, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12348, 194, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12349, 194, 4, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12350, 194, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12351, 195, 1, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12352, 195, 2, 1, 3);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12353, 195, 3, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12354, 195, 4, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12355, 195, 5, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12356, 195, 1, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12357, 195, 2, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12358, 195, 3, 2, 27);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12359, 195, 4, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12360, 195, 5, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12361, 195, 1, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12362, 195, 2, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12363, 195, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12364, 195, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12365, 195, 5, 3, 35);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12366, 195, 1, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12367, 195, 2, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12368, 195, 3, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12369, 195, 4, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12370, 195, 5, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12371, 195, 1, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12372, 195, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12373, 195, 3, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12374, 195, 4, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12375, 195, 5, 5, 62);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12376, 196, 1, 1, 2);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12377, 196, 2, 1, 9);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12378, 196, 3, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12379, 196, 4, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12380, 196, 5, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12381, 196, 1, 2, 26);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12382, 196, 2, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12383, 196, 3, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12384, 196, 4, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12385, 196, 5, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12386, 196, 1, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12387, 196, 2, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12388, 196, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12389, 196, 4, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12390, 196, 5, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12391, 196, 1, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12392, 196, 2, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12393, 196, 3, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12394, 196, 4, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12395, 196, 5, 4, 58);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12396, 196, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12397, 196, 2, 5, 61);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12398, 196, 3, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12399, 196, 4, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12400, 196, 5, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12401, 197, 1, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12402, 197, 2, 1, 14);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12403, 197, 3, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12404, 197, 4, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12405, 197, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12406, 197, 1, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12407, 197, 2, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12408, 197, 3, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12409, 197, 4, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12410, 197, 5, 2, 28);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12411, 197, 1, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12412, 197, 2, 3, 43);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12413, 197, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12414, 197, 4, 3, 32);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12415, 197, 5, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12416, 197, 1, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12417, 197, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12418, 197, 3, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12419, 197, 4, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12420, 197, 5, 4, 50);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12421, 197, 1, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12422, 197, 2, 5, 70);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12423, 197, 3, 5, 68);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12424, 197, 4, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12425, 197, 5, 5, 63);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12426, 198, 1, 1, 8);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12427, 198, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12428, 198, 3, 1, 10);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12429, 198, 4, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12430, 198, 5, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12431, 198, 1, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12432, 198, 2, 2, 22);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12433, 198, 3, 2, 19);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12434, 198, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12435, 198, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12436, 198, 1, 3, 31);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12437, 198, 2, 3, 37);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12438, 198, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12439, 198, 4, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12440, 198, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12441, 198, 1, 4, 51);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12442, 198, 2, 4, 54);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12443, 198, 3, 4, 48);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12444, 198, 4, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12445, 198, 5, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12446, 198, 1, 5, 65);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12447, 198, 2, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12448, 198, 3, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12449, 198, 4, 5, 73);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12450, 198, 5, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12451, 199, 1, 1, 15);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12452, 199, 2, 1, 7);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12453, 199, 3, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12454, 199, 4, 1, 1);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12455, 199, 5, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12456, 199, 1, 2, 20);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12457, 199, 2, 2, 24);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12458, 199, 3, 2, 23);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12459, 199, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12460, 199, 5, 2, 18);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12461, 199, 1, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12462, 199, 2, 3, 39);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12463, 199, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12464, 199, 4, 3, 36);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12465, 199, 5, 3, 41);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12466, 199, 1, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12467, 199, 2, 4, 59);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12468, 199, 3, 4, 55);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12469, 199, 4, 4, 56);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12470, 199, 5, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12471, 199, 1, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12472, 199, 2, 5, 64);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12473, 199, 3, 5, 74);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12474, 199, 4, 5, 72);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12475, 199, 5, 5, 75);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12476, 200, 1, 1, 6);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12477, 200, 2, 1, 12);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12478, 200, 3, 1, 4);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12479, 200, 4, 1, 13);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12480, 200, 5, 1, 11);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12481, 200, 1, 2, 25);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12482, 200, 2, 2, 17);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12483, 200, 3, 2, 16);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12484, 200, 4, 2, 21);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12485, 200, 5, 2, 29);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12486, 200, 1, 3, 33);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12487, 200, 2, 3, 34);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12488, 200, 3, 3, NULL);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12489, 200, 4, 3, 45);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12490, 200, 5, 3, 38);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12491, 200, 1, 4, 47);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12492, 200, 2, 4, 60);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12493, 200, 3, 4, 57);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12494, 200, 4, 4, 52);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12495, 200, 5, 4, 53);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12496, 200, 1, 5, 67);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12497, 200, 2, 5, 69);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12498, 200, 3, 5, 66);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12499, 200, 4, 5, 71);
INSERT INTO public.master_card_numbers OVERRIDING SYSTEM VALUE VALUES (12500, 200, 5, 5, 75);


--
-- TOC entry 4906 (class 0 OID 30222)
-- Dependencies: 228
-- Data for Name: master_cards; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.master_cards VALUES (1);
INSERT INTO public.master_cards VALUES (2);
INSERT INTO public.master_cards VALUES (3);
INSERT INTO public.master_cards VALUES (4);
INSERT INTO public.master_cards VALUES (5);
INSERT INTO public.master_cards VALUES (6);
INSERT INTO public.master_cards VALUES (7);
INSERT INTO public.master_cards VALUES (8);
INSERT INTO public.master_cards VALUES (9);
INSERT INTO public.master_cards VALUES (10);
INSERT INTO public.master_cards VALUES (11);
INSERT INTO public.master_cards VALUES (12);
INSERT INTO public.master_cards VALUES (13);
INSERT INTO public.master_cards VALUES (14);
INSERT INTO public.master_cards VALUES (15);
INSERT INTO public.master_cards VALUES (16);
INSERT INTO public.master_cards VALUES (17);
INSERT INTO public.master_cards VALUES (18);
INSERT INTO public.master_cards VALUES (19);
INSERT INTO public.master_cards VALUES (20);
INSERT INTO public.master_cards VALUES (21);
INSERT INTO public.master_cards VALUES (22);
INSERT INTO public.master_cards VALUES (23);
INSERT INTO public.master_cards VALUES (24);
INSERT INTO public.master_cards VALUES (25);
INSERT INTO public.master_cards VALUES (26);
INSERT INTO public.master_cards VALUES (27);
INSERT INTO public.master_cards VALUES (28);
INSERT INTO public.master_cards VALUES (29);
INSERT INTO public.master_cards VALUES (30);
INSERT INTO public.master_cards VALUES (31);
INSERT INTO public.master_cards VALUES (32);
INSERT INTO public.master_cards VALUES (33);
INSERT INTO public.master_cards VALUES (34);
INSERT INTO public.master_cards VALUES (35);
INSERT INTO public.master_cards VALUES (36);
INSERT INTO public.master_cards VALUES (37);
INSERT INTO public.master_cards VALUES (38);
INSERT INTO public.master_cards VALUES (39);
INSERT INTO public.master_cards VALUES (40);
INSERT INTO public.master_cards VALUES (41);
INSERT INTO public.master_cards VALUES (42);
INSERT INTO public.master_cards VALUES (43);
INSERT INTO public.master_cards VALUES (44);
INSERT INTO public.master_cards VALUES (45);
INSERT INTO public.master_cards VALUES (46);
INSERT INTO public.master_cards VALUES (47);
INSERT INTO public.master_cards VALUES (48);
INSERT INTO public.master_cards VALUES (49);
INSERT INTO public.master_cards VALUES (50);
INSERT INTO public.master_cards VALUES (51);
INSERT INTO public.master_cards VALUES (52);
INSERT INTO public.master_cards VALUES (53);
INSERT INTO public.master_cards VALUES (54);
INSERT INTO public.master_cards VALUES (55);
INSERT INTO public.master_cards VALUES (56);
INSERT INTO public.master_cards VALUES (57);
INSERT INTO public.master_cards VALUES (58);
INSERT INTO public.master_cards VALUES (59);
INSERT INTO public.master_cards VALUES (60);
INSERT INTO public.master_cards VALUES (61);
INSERT INTO public.master_cards VALUES (62);
INSERT INTO public.master_cards VALUES (63);
INSERT INTO public.master_cards VALUES (64);
INSERT INTO public.master_cards VALUES (65);
INSERT INTO public.master_cards VALUES (66);
INSERT INTO public.master_cards VALUES (67);
INSERT INTO public.master_cards VALUES (68);
INSERT INTO public.master_cards VALUES (69);
INSERT INTO public.master_cards VALUES (70);
INSERT INTO public.master_cards VALUES (71);
INSERT INTO public.master_cards VALUES (72);
INSERT INTO public.master_cards VALUES (73);
INSERT INTO public.master_cards VALUES (74);
INSERT INTO public.master_cards VALUES (75);
INSERT INTO public.master_cards VALUES (76);
INSERT INTO public.master_cards VALUES (77);
INSERT INTO public.master_cards VALUES (78);
INSERT INTO public.master_cards VALUES (79);
INSERT INTO public.master_cards VALUES (80);
INSERT INTO public.master_cards VALUES (81);
INSERT INTO public.master_cards VALUES (82);
INSERT INTO public.master_cards VALUES (83);
INSERT INTO public.master_cards VALUES (84);
INSERT INTO public.master_cards VALUES (85);
INSERT INTO public.master_cards VALUES (86);
INSERT INTO public.master_cards VALUES (87);
INSERT INTO public.master_cards VALUES (88);
INSERT INTO public.master_cards VALUES (89);
INSERT INTO public.master_cards VALUES (90);
INSERT INTO public.master_cards VALUES (91);
INSERT INTO public.master_cards VALUES (92);
INSERT INTO public.master_cards VALUES (93);
INSERT INTO public.master_cards VALUES (94);
INSERT INTO public.master_cards VALUES (95);
INSERT INTO public.master_cards VALUES (96);
INSERT INTO public.master_cards VALUES (97);
INSERT INTO public.master_cards VALUES (98);
INSERT INTO public.master_cards VALUES (99);
INSERT INTO public.master_cards VALUES (100);
INSERT INTO public.master_cards VALUES (101);
INSERT INTO public.master_cards VALUES (102);
INSERT INTO public.master_cards VALUES (103);
INSERT INTO public.master_cards VALUES (104);
INSERT INTO public.master_cards VALUES (105);
INSERT INTO public.master_cards VALUES (106);
INSERT INTO public.master_cards VALUES (107);
INSERT INTO public.master_cards VALUES (108);
INSERT INTO public.master_cards VALUES (109);
INSERT INTO public.master_cards VALUES (110);
INSERT INTO public.master_cards VALUES (111);
INSERT INTO public.master_cards VALUES (112);
INSERT INTO public.master_cards VALUES (113);
INSERT INTO public.master_cards VALUES (114);
INSERT INTO public.master_cards VALUES (115);
INSERT INTO public.master_cards VALUES (116);
INSERT INTO public.master_cards VALUES (117);
INSERT INTO public.master_cards VALUES (118);
INSERT INTO public.master_cards VALUES (119);
INSERT INTO public.master_cards VALUES (120);
INSERT INTO public.master_cards VALUES (121);
INSERT INTO public.master_cards VALUES (122);
INSERT INTO public.master_cards VALUES (123);
INSERT INTO public.master_cards VALUES (124);
INSERT INTO public.master_cards VALUES (125);
INSERT INTO public.master_cards VALUES (126);
INSERT INTO public.master_cards VALUES (127);
INSERT INTO public.master_cards VALUES (128);
INSERT INTO public.master_cards VALUES (129);
INSERT INTO public.master_cards VALUES (130);
INSERT INTO public.master_cards VALUES (131);
INSERT INTO public.master_cards VALUES (132);
INSERT INTO public.master_cards VALUES (133);
INSERT INTO public.master_cards VALUES (134);
INSERT INTO public.master_cards VALUES (135);
INSERT INTO public.master_cards VALUES (136);
INSERT INTO public.master_cards VALUES (137);
INSERT INTO public.master_cards VALUES (138);
INSERT INTO public.master_cards VALUES (139);
INSERT INTO public.master_cards VALUES (140);
INSERT INTO public.master_cards VALUES (141);
INSERT INTO public.master_cards VALUES (142);
INSERT INTO public.master_cards VALUES (143);
INSERT INTO public.master_cards VALUES (144);
INSERT INTO public.master_cards VALUES (145);
INSERT INTO public.master_cards VALUES (146);
INSERT INTO public.master_cards VALUES (147);
INSERT INTO public.master_cards VALUES (148);
INSERT INTO public.master_cards VALUES (149);
INSERT INTO public.master_cards VALUES (150);
INSERT INTO public.master_cards VALUES (151);
INSERT INTO public.master_cards VALUES (152);
INSERT INTO public.master_cards VALUES (153);
INSERT INTO public.master_cards VALUES (154);
INSERT INTO public.master_cards VALUES (155);
INSERT INTO public.master_cards VALUES (156);
INSERT INTO public.master_cards VALUES (157);
INSERT INTO public.master_cards VALUES (158);
INSERT INTO public.master_cards VALUES (159);
INSERT INTO public.master_cards VALUES (160);
INSERT INTO public.master_cards VALUES (161);
INSERT INTO public.master_cards VALUES (162);
INSERT INTO public.master_cards VALUES (163);
INSERT INTO public.master_cards VALUES (164);
INSERT INTO public.master_cards VALUES (165);
INSERT INTO public.master_cards VALUES (166);
INSERT INTO public.master_cards VALUES (167);
INSERT INTO public.master_cards VALUES (168);
INSERT INTO public.master_cards VALUES (169);
INSERT INTO public.master_cards VALUES (170);
INSERT INTO public.master_cards VALUES (171);
INSERT INTO public.master_cards VALUES (172);
INSERT INTO public.master_cards VALUES (173);
INSERT INTO public.master_cards VALUES (174);
INSERT INTO public.master_cards VALUES (175);
INSERT INTO public.master_cards VALUES (176);
INSERT INTO public.master_cards VALUES (177);
INSERT INTO public.master_cards VALUES (178);
INSERT INTO public.master_cards VALUES (179);
INSERT INTO public.master_cards VALUES (180);
INSERT INTO public.master_cards VALUES (181);
INSERT INTO public.master_cards VALUES (182);
INSERT INTO public.master_cards VALUES (183);
INSERT INTO public.master_cards VALUES (184);
INSERT INTO public.master_cards VALUES (185);
INSERT INTO public.master_cards VALUES (186);
INSERT INTO public.master_cards VALUES (187);
INSERT INTO public.master_cards VALUES (188);
INSERT INTO public.master_cards VALUES (189);
INSERT INTO public.master_cards VALUES (190);
INSERT INTO public.master_cards VALUES (191);
INSERT INTO public.master_cards VALUES (192);
INSERT INTO public.master_cards VALUES (193);
INSERT INTO public.master_cards VALUES (194);
INSERT INTO public.master_cards VALUES (195);
INSERT INTO public.master_cards VALUES (196);
INSERT INTO public.master_cards VALUES (197);
INSERT INTO public.master_cards VALUES (198);
INSERT INTO public.master_cards VALUES (199);
INSERT INTO public.master_cards VALUES (200);


--
-- TOC entry 4910 (class 0 OID 42050)
-- Dependencies: 232
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4899 (class 0 OID 24888)
-- Dependencies: 221
-- Data for Name: room_players; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4897 (class 0 OID 24870)
-- Dependencies: 219
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4895 (class 0 OID 24837)
-- Dependencies: 217
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4905 (class 0 OID 24964)
-- Dependencies: 227
-- Data for Name: wins; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4916 (class 0 OID 0)
-- Dependencies: 224
-- Name: called_numbers_called_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.called_numbers_called_id_seq', 7701, true);


--
-- TOC entry 4917 (class 0 OID 0)
-- Dependencies: 222
-- Name: cards_card_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cards_card_id_seq', 467, true);


--
-- TOC entry 4918 (class 0 OID 0)
-- Dependencies: 229
-- Name: master_card_numbers_master_card_number_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.master_card_numbers_master_card_number_id_seq', 12500, true);


--
-- TOC entry 4919 (class 0 OID 0)
-- Dependencies: 231
-- Name: payments_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_payment_id_seq', 2, true);


--
-- TOC entry 4920 (class 0 OID 0)
-- Dependencies: 220
-- Name: room_players_room_player_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.room_players_room_player_id_seq', 300, true);


--
-- TOC entry 4921 (class 0 OID 0)
-- Dependencies: 218
-- Name: rooms_room_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rooms_room_id_seq', 155, true);


--
-- TOC entry 4922 (class 0 OID 0)
-- Dependencies: 226
-- Name: wins_win_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wins_win_id_seq', 9, true);


--
-- TOC entry 4732 (class 2606 OID 30232)
-- Name: master_card_numbers PK_master_card_numbers; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.master_card_numbers
    ADD CONSTRAINT "PK_master_card_numbers" PRIMARY KEY (master_card_number_id);


--
-- TOC entry 4729 (class 2606 OID 30226)
-- Name: master_cards PK_master_cards; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.master_cards
    ADD CONSTRAINT "PK_master_cards" PRIMARY KEY (master_card_id);


--
-- TOC entry 4721 (class 2606 OID 24946)
-- Name: called_numbers called_numbers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.called_numbers
    ADD CONSTRAINT called_numbers_pkey PRIMARY KEY (called_id);


--
-- TOC entry 4723 (class 2606 OID 30215)
-- Name: called_numbers called_numbers_room_id_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.called_numbers
    ADD CONSTRAINT called_numbers_room_id_number_key UNIQUE (room_id, number);


--
-- TOC entry 4717 (class 2606 OID 24913)
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (card_id);


--
-- TOC entry 4735 (class 2606 OID 42055)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- TOC entry 4711 (class 2606 OID 24894)
-- Name: room_players room_players_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.room_players
    ADD CONSTRAINT room_players_pkey PRIMARY KEY (room_player_id);


--
-- TOC entry 4713 (class 2606 OID 24896)
-- Name: room_players room_players_room_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.room_players
    ADD CONSTRAINT room_players_room_id_user_id_key UNIQUE (room_id, user_id);


--
-- TOC entry 4706 (class 2606 OID 24879)
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (room_id);


--
-- TOC entry 4708 (class 2606 OID 24881)
-- Name: rooms rooms_room_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_room_code_key UNIQUE (room_code);


--
-- TOC entry 4737 (class 2606 OID 42057)
-- Name: payments uk_transaction_reference; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT uk_transaction_reference UNIQUE (transaction_reference);


--
-- TOC entry 4699 (class 2606 OID 24848)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (phone_number);


--
-- TOC entry 4701 (class 2606 OID 24844)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 4703 (class 2606 OID 24846)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 4727 (class 2606 OID 24972)
-- Name: wins wins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wins
    ADD CONSTRAINT wins_pkey PRIMARY KEY (win_id);


--
-- TOC entry 4714 (class 1259 OID 30238)
-- Name: IX_cards_master_card_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_cards_master_card_id" ON public.cards USING btree (master_card_id);


--
-- TOC entry 4715 (class 1259 OID 30239)
-- Name: IX_cards_room_id_user_id_master_card_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_cards_room_id_user_id_master_card_id" ON public.cards USING btree (room_id, user_id, master_card_id);


--
-- TOC entry 4730 (class 1259 OID 30240)
-- Name: IX_master_card_numbers_master_card_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_master_card_numbers_master_card_id" ON public.master_card_numbers USING btree (master_card_id);


--
-- TOC entry 4724 (class 1259 OID 25011)
-- Name: idx_called_numbers_room_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_called_numbers_room_id ON public.called_numbers USING btree (room_id);


--
-- TOC entry 4718 (class 1259 OID 25008)
-- Name: idx_cards_room_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cards_room_id ON public.cards USING btree (room_id);


--
-- TOC entry 4719 (class 1259 OID 25009)
-- Name: idx_cards_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cards_user_id ON public.cards USING btree (user_id);


--
-- TOC entry 4733 (class 1259 OID 42063)
-- Name: idx_payments_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_user_id ON public.payments USING btree (user_id);


--
-- TOC entry 4709 (class 1259 OID 25007)
-- Name: idx_room_players_room_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_room_players_room_id ON public.room_players USING btree (room_id);


--
-- TOC entry 4704 (class 1259 OID 42042)
-- Name: idx_room_start; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_room_start ON public.rooms USING btree (status, scheduled_start_time);


--
-- TOC entry 4725 (class 1259 OID 25012)
-- Name: idx_wins_room_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_wins_room_id ON public.wins USING btree (room_id);


--
-- TOC entry 4749 (class 2620 OID 24850)
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4740 (class 2606 OID 30241)
-- Name: cards FK_cards_master_cards_master_card_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT "FK_cards_master_cards_master_card_id" FOREIGN KEY (master_card_id) REFERENCES public.master_cards(master_card_id) ON DELETE RESTRICT;


--
-- TOC entry 4747 (class 2606 OID 30233)
-- Name: master_card_numbers FK_master_card_numbers_master_cards_master_card_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.master_card_numbers
    ADD CONSTRAINT "FK_master_card_numbers_master_cards_master_card_id" FOREIGN KEY (master_card_id) REFERENCES public.master_cards(master_card_id) ON DELETE CASCADE;


--
-- TOC entry 4744 (class 2606 OID 24978)
-- Name: wins fk_card; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wins
    ADD CONSTRAINT fk_card FOREIGN KEY (card_id) REFERENCES public.cards(card_id) ON DELETE CASCADE;


--
-- TOC entry 4748 (class 2606 OID 42058)
-- Name: payments fk_payment_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT fk_payment_user FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 4738 (class 2606 OID 24897)
-- Name: room_players fk_room; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.room_players
    ADD CONSTRAINT fk_room FOREIGN KEY (room_id) REFERENCES public.rooms(room_id) ON DELETE CASCADE;


--
-- TOC entry 4741 (class 2606 OID 24914)
-- Name: cards fk_room; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT fk_room FOREIGN KEY (room_id) REFERENCES public.rooms(room_id) ON DELETE CASCADE;


--
-- TOC entry 4743 (class 2606 OID 24949)
-- Name: called_numbers fk_room; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.called_numbers
    ADD CONSTRAINT fk_room FOREIGN KEY (room_id) REFERENCES public.rooms(room_id) ON DELETE CASCADE;


--
-- TOC entry 4745 (class 2606 OID 24973)
-- Name: wins fk_room; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wins
    ADD CONSTRAINT fk_room FOREIGN KEY (room_id) REFERENCES public.rooms(room_id) ON DELETE CASCADE;


--
-- TOC entry 4739 (class 2606 OID 24902)
-- Name: room_players fk_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.room_players
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 4742 (class 2606 OID 24919)
-- Name: cards fk_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 4746 (class 2606 OID 24983)
-- Name: wins fk_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wins
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


-- Completed on 2026-01-31 23:46:11

--
-- PostgreSQL database dump complete
--

