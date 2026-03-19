--
-- PostgreSQL database dump
--

\restrict 40bXE6JdjL8yaTix6JfByhk4gOekewOGlDlMBplCwoah9LV8vPEmOPmGuiJpv9e

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-03-18 23:38:53

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 16418)
-- Name: areas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.areas (
    id_area integer NOT NULL,
    nombre_area character varying(50) NOT NULL
);


ALTER TABLE public.areas OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16417)
-- Name: areas_id_area_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.areas_id_area_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.areas_id_area_seq OWNER TO postgres;

--
-- TOC entry 5090 (class 0 OID 0)
-- Dependencies: 221
-- Name: areas_id_area_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.areas_id_area_seq OWNED BY public.areas.id_area;


--
-- TOC entry 227 (class 1259 OID 16459)
-- Name: asignaciones_areas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.asignaciones_areas (
    id_asignacion integer NOT NULL,
    id_empleado integer NOT NULL,
    id_area integer NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date NOT NULL
);


ALTER TABLE public.asignaciones_areas OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16458)
-- Name: asignaciones_areas_id_asignacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.asignaciones_areas_id_asignacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.asignaciones_areas_id_asignacion_seq OWNER TO postgres;

--
-- TOC entry 5091 (class 0 OID 0)
-- Dependencies: 226
-- Name: asignaciones_areas_id_asignacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.asignaciones_areas_id_asignacion_seq OWNED BY public.asignaciones_areas.id_asignacion;


--
-- TOC entry 220 (class 1259 OID 16404)
-- Name: empleados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.empleados (
    id_empleado integer NOT NULL,
    usuario character varying(20) NOT NULL,
    password character varying(10) NOT NULL,
    rol character varying(20) NOT NULL,
    CONSTRAINT empleados_rol_check CHECK (((rol)::text = ANY ((ARRAY['lider'::character varying, 'encargado'::character varying, 'colaborador'::character varying])::text[])))
);


ALTER TABLE public.empleados OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16403)
-- Name: empleados_id_empleado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.empleados_id_empleado_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.empleados_id_empleado_seq OWNER TO postgres;

--
-- TOC entry 5092 (class 0 OID 0)
-- Dependencies: 219
-- Name: empleados_id_empleado_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.empleados_id_empleado_seq OWNED BY public.empleados.id_empleado;


--
-- TOC entry 231 (class 1259 OID 16507)
-- Name: historial_retiros; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historial_retiros (
    id_retiro integer NOT NULL,
    id_lote integer NOT NULL,
    fecha_retiro timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    id_empleado integer NOT NULL
);


ALTER TABLE public.historial_retiros OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16506)
-- Name: historial_retiros_id_retiro_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.historial_retiros_id_retiro_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.historial_retiros_id_retiro_seq OWNER TO postgres;

--
-- TOC entry 5093 (class 0 OID 0)
-- Dependencies: 230
-- Name: historial_retiros_id_retiro_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.historial_retiros_id_retiro_seq OWNED BY public.historial_retiros.id_retiro;


--
-- TOC entry 229 (class 1259 OID 16481)
-- Name: lotes_productos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lotes_productos (
    id_lote integer NOT NULL,
    codigo_barras character varying(20) NOT NULL,
    fecha_caducidad date NOT NULL,
    cantidad integer NOT NULL,
    fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    id_empleado integer NOT NULL,
    estado character varying(20) DEFAULT 'activo'::character varying,
    CONSTRAINT lotes_productos_cantidad_check CHECK ((cantidad > 0)),
    CONSTRAINT lotes_productos_estado_check CHECK (((estado)::text = ANY ((ARRAY['activo'::character varying, 'retirado'::character varying])::text[])))
);


ALTER TABLE public.lotes_productos OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16480)
-- Name: lotes_productos_id_lote_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lotes_productos_id_lote_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lotes_productos_id_lote_seq OWNER TO postgres;

--
-- TOC entry 5094 (class 0 OID 0)
-- Dependencies: 228
-- Name: lotes_productos_id_lote_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lotes_productos_id_lote_seq OWNED BY public.lotes_productos.id_lote;


--
-- TOC entry 225 (class 1259 OID 16439)
-- Name: productos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productos (
    codigo_barras character varying(20) NOT NULL,
    nombre_producto character varying(150) NOT NULL,
    id_proveedor integer NOT NULL,
    id_area integer NOT NULL
);


ALTER TABLE public.productos OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16429)
-- Name: proveedores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proveedores (
    id_proveedor integer NOT NULL,
    nombre_proveedor character varying(100) NOT NULL
);


ALTER TABLE public.proveedores OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16428)
-- Name: proveedores_id_proveedor_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.proveedores_id_proveedor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.proveedores_id_proveedor_seq OWNER TO postgres;

--
-- TOC entry 5095 (class 0 OID 0)
-- Dependencies: 223
-- Name: proveedores_id_proveedor_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proveedores_id_proveedor_seq OWNED BY public.proveedores.id_proveedor;


--
-- TOC entry 4886 (class 2604 OID 16421)
-- Name: areas id_area; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.areas ALTER COLUMN id_area SET DEFAULT nextval('public.areas_id_area_seq'::regclass);


--
-- TOC entry 4888 (class 2604 OID 16462)
-- Name: asignaciones_areas id_asignacion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asignaciones_areas ALTER COLUMN id_asignacion SET DEFAULT nextval('public.asignaciones_areas_id_asignacion_seq'::regclass);


--
-- TOC entry 4885 (class 2604 OID 16407)
-- Name: empleados id_empleado; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleados ALTER COLUMN id_empleado SET DEFAULT nextval('public.empleados_id_empleado_seq'::regclass);


--
-- TOC entry 4892 (class 2604 OID 16510)
-- Name: historial_retiros id_retiro; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_retiros ALTER COLUMN id_retiro SET DEFAULT nextval('public.historial_retiros_id_retiro_seq'::regclass);


--
-- TOC entry 4889 (class 2604 OID 16484)
-- Name: lotes_productos id_lote; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lotes_productos ALTER COLUMN id_lote SET DEFAULT nextval('public.lotes_productos_id_lote_seq'::regclass);


--
-- TOC entry 4887 (class 2604 OID 16432)
-- Name: proveedores id_proveedor; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedores ALTER COLUMN id_proveedor SET DEFAULT nextval('public.proveedores_id_proveedor_seq'::regclass);


--
-- TOC entry 5075 (class 0 OID 16418)
-- Dependencies: 222
-- Data for Name: areas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.areas (id_area, nombre_area) FROM stdin;
1	Abarrotes
2	Bebés y mascotas
3	Bebidas
4	Botanas y snacks
5	Cerveza, vinos y licores
6	Cuidado personal y belleza
7	Dulcería y confitería
8	Fast food
9	Hogar y limpieza
10	Lácteos y refrigerados
11	Mercancías generales
12	Panadería y repostería
\.


--
-- TOC entry 5080 (class 0 OID 16459)
-- Dependencies: 227
-- Data for Name: asignaciones_areas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.asignaciones_areas (id_asignacion, id_empleado, id_area, fecha_inicio, fecha_fin) FROM stdin;
\.


--
-- TOC entry 5073 (class 0 OID 16404)
-- Dependencies: 220
-- Data for Name: empleados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.empleados (id_empleado, usuario, password, rol) FROM stdin;
1	01EMP93	1234	lider
2	02EMP29	1980	encargado
3	03EMP68	2003	colaborador
4	04EMP70	2002	colaborador
\.


--
-- TOC entry 5084 (class 0 OID 16507)
-- Dependencies: 231
-- Data for Name: historial_retiros; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.historial_retiros (id_retiro, id_lote, fecha_retiro, id_empleado) FROM stdin;
\.


--
-- TOC entry 5082 (class 0 OID 16481)
-- Dependencies: 229
-- Data for Name: lotes_productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lotes_productos (id_lote, codigo_barras, fecha_caducidad, cantidad, fecha_registro, id_empleado, estado) FROM stdin;
1	7500478005581	2026-05-28	2	2026-03-08 01:35:20.094905	2	activo
2	7500810016190	2026-05-01	2	2026-03-08 01:35:39.937611	2	activo
3	7500478005581	2026-03-25	1	2026-03-08 01:36:13.319919	2	activo
4	7500478005581	2026-08-14	1	2026-03-08 01:36:30.083005	2	activo
5	7500810016190	2026-06-05	55	2026-03-08 20:35:41.773733	2	activo
6	7500810016190	2026-03-23	1	2026-03-08 21:06:13.428442	2	activo
7	7500810016190	2026-05-20	4	2026-03-08 21:24:03.259933	2	activo
8	7500810016190	2026-04-12	6	2026-03-08 21:49:12.14114	2	activo
9	7500478005581	2026-03-29	25	2026-03-08 22:01:27.878343	2	activo
10	7500478005581	2026-04-29	1	2026-03-08 22:02:03.600476	2	activo
11	7500478005581	2026-03-30	13	2026-03-09 15:33:09.947914	2	activo
12	7500810016190	2026-03-26	1	2026-03-11 18:40:10.582691	2	activo
13	7500478005581	2027-03-01	1	2026-03-15 00:24:29.171651	2	activo
14	7500478005581	2026-03-31	1	2026-03-17 14:21:10.036387	2	activo
15	7500478005581	2026-06-24	25	2026-03-17 14:44:36.065686	2	activo
16	7500810016190	2026-04-23	58	2026-03-17 14:46:01.800983	2	activo
17	7500478005581	2026-03-22	11	2026-03-17 14:54:49.497955	2	activo
18	7500478005581	2026-05-13	15	2026-03-17 14:57:41.579959	2	activo
\.


--
-- TOC entry 5078 (class 0 OID 16439)
-- Dependencies: 225
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.productos (codigo_barras, nombre_producto, id_proveedor, id_area) FROM stdin;
7500810016190	Tartinas De Piña 133.3gr	13	7
7500478005581	Galletas Pan Crema 151 g	7	7
\.


--
-- TOC entry 5077 (class 0 OID 16429)
-- Dependencies: 224
-- Data for Name: proveedores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.proveedores (id_proveedor, nombre_proveedor) FROM stdin;
1	Barcel
2	Bimbo
3	CEDIS
4	Cervecería Cuauhtémoc Moctezuma
5	Cervecería Modelo
6	Coca-Cola
7	Gamesa
8	Holanda
9	LALA
10	Marinela
11	Sabritas
12	SIGMA
13	Tía Rosa
\.


--
-- TOC entry 5096 (class 0 OID 0)
-- Dependencies: 221
-- Name: areas_id_area_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.areas_id_area_seq', 12, true);


--
-- TOC entry 5097 (class 0 OID 0)
-- Dependencies: 226
-- Name: asignaciones_areas_id_asignacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.asignaciones_areas_id_asignacion_seq', 1, false);


--
-- TOC entry 5098 (class 0 OID 0)
-- Dependencies: 219
-- Name: empleados_id_empleado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.empleados_id_empleado_seq', 4, true);


--
-- TOC entry 5099 (class 0 OID 0)
-- Dependencies: 230
-- Name: historial_retiros_id_retiro_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.historial_retiros_id_retiro_seq', 1, false);


--
-- TOC entry 5100 (class 0 OID 0)
-- Dependencies: 228
-- Name: lotes_productos_id_lote_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lotes_productos_id_lote_seq', 18, true);


--
-- TOC entry 5101 (class 0 OID 0)
-- Dependencies: 223
-- Name: proveedores_id_proveedor_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.proveedores_id_proveedor_seq', 13, true);


--
-- TOC entry 4902 (class 2606 OID 16427)
-- Name: areas areas_nombre_area_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.areas
    ADD CONSTRAINT areas_nombre_area_key UNIQUE (nombre_area);


--
-- TOC entry 4904 (class 2606 OID 16425)
-- Name: areas areas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.areas
    ADD CONSTRAINT areas_pkey PRIMARY KEY (id_area);


--
-- TOC entry 4912 (class 2606 OID 16469)
-- Name: asignaciones_areas asignaciones_areas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asignaciones_areas
    ADD CONSTRAINT asignaciones_areas_pkey PRIMARY KEY (id_asignacion);


--
-- TOC entry 4898 (class 2606 OID 16414)
-- Name: empleados empleados_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_pkey PRIMARY KEY (id_empleado);


--
-- TOC entry 4900 (class 2606 OID 16416)
-- Name: empleados empleados_usuario_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_usuario_key UNIQUE (usuario);


--
-- TOC entry 4916 (class 2606 OID 16516)
-- Name: historial_retiros historial_retiros_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_retiros
    ADD CONSTRAINT historial_retiros_pkey PRIMARY KEY (id_retiro);


--
-- TOC entry 4914 (class 2606 OID 16495)
-- Name: lotes_productos lotes_productos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lotes_productos
    ADD CONSTRAINT lotes_productos_pkey PRIMARY KEY (id_lote);


--
-- TOC entry 4910 (class 2606 OID 16573)
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (codigo_barras);


--
-- TOC entry 4906 (class 2606 OID 16438)
-- Name: proveedores proveedores_nombre_proveedor_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_nombre_proveedor_key UNIQUE (nombre_proveedor);


--
-- TOC entry 4908 (class 2606 OID 16436)
-- Name: proveedores proveedores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_pkey PRIMARY KEY (id_proveedor);


--
-- TOC entry 4919 (class 2606 OID 16475)
-- Name: asignaciones_areas asignaciones_areas_id_area_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asignaciones_areas
    ADD CONSTRAINT asignaciones_areas_id_area_fkey FOREIGN KEY (id_area) REFERENCES public.areas(id_area);


--
-- TOC entry 4920 (class 2606 OID 16470)
-- Name: asignaciones_areas asignaciones_areas_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asignaciones_areas
    ADD CONSTRAINT asignaciones_areas_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- TOC entry 4923 (class 2606 OID 16522)
-- Name: historial_retiros historial_retiros_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_retiros
    ADD CONSTRAINT historial_retiros_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- TOC entry 4924 (class 2606 OID 16517)
-- Name: historial_retiros historial_retiros_id_lote_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_retiros
    ADD CONSTRAINT historial_retiros_id_lote_fkey FOREIGN KEY (id_lote) REFERENCES public.lotes_productos(id_lote);


--
-- TOC entry 4921 (class 2606 OID 16584)
-- Name: lotes_productos lotes_productos_codigo_barras_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lotes_productos
    ADD CONSTRAINT lotes_productos_codigo_barras_fkey FOREIGN KEY (codigo_barras) REFERENCES public.productos(codigo_barras);


--
-- TOC entry 4922 (class 2606 OID 16501)
-- Name: lotes_productos lotes_productos_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lotes_productos
    ADD CONSTRAINT lotes_productos_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


--
-- TOC entry 4917 (class 2606 OID 16453)
-- Name: productos productos_id_area_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_id_area_fkey FOREIGN KEY (id_area) REFERENCES public.areas(id_area);


--
-- TOC entry 4918 (class 2606 OID 16448)
-- Name: productos productos_id_proveedor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_id_proveedor_fkey FOREIGN KEY (id_proveedor) REFERENCES public.proveedores(id_proveedor);


-- Completed on 2026-03-18 23:38:54

--
-- PostgreSQL database dump complete
--

\unrestrict 40bXE6JdjL8yaTix6JfByhk4gOekewOGlDlMBplCwoah9LV8vPEmOPmGuiJpv9e

