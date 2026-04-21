-- =============================================================
-- SCRIPT DE DATOS DEMO - AURA SALA DE BELLEZA
-- Elimina datos del negocio anterior e inserta datos de salón
-- =============================================================
BEGIN;

-- ─────────────────────────────────────────────────────────────
-- 1. LIMPIAR DATOS ANTERIORES (orden inverso de dependencias)
-- ─────────────────────────────────────────────────────────────

-- POS
DELETE FROM public.pos_ventas_detalle;
DELETE FROM public.pos_ventas;
DELETE FROM public.pos_clientes_puntos;

-- Auditoría
DELETE FROM public.auditoria;

-- Eventos personal
DELETE FROM public.eventos_personal;

-- Inventarios
DELETE FROM public.inventarios_movimientos;
DELETE FROM public.inv_tabulador_precios;
DELETE FROM public.inventarios;
DELETE FROM public.inv_departamentos;

-- Equipos
DELETE FROM public.equipos_historial_contador;
DELETE FROM public.equipos_mantenimiento;
DELETE FROM public.equipos_consumibles;
DELETE FROM public.equipos_caracteristicas;
DELETE FROM public.equipos;

-- Empleados / Usuarios (preservar admin id=1 y Jhonatan id=6)
DELETE FROM public.empleados_modulos;

-- Romper referencias cruzadas usuarios <-> empleados
UPDATE public.empleados SET usuario_id = NULL;
UPDATE public.usuarios SET empleado_id = NULL WHERE id NOT IN (1,6);

DELETE FROM public.usuarios WHERE id NOT IN (1, 6);
DELETE FROM public.empleados WHERE id NOT IN (11); -- conservar Jhonatan empleado id=11

-- Datos maestros de negocio anterior
DELETE FROM public.clientes;
DELETE FROM public.proveedores;

-- Catálogos de equipo (se reemplazan)
DELETE FROM public.cat_tipos_equipo;
DELETE FROM public.cat_marcas_equipo;

-- Anular FKs del empleado conservado antes de borrar catálogos
UPDATE public.empleados SET puesto_id = NULL, sucursal_id = NULL WHERE id = 11;

-- Puestos y sucursales
DELETE FROM public.puestos;
DELETE FROM public.sucursales;

-- ─────────────────────────────────────────────────────────────
-- 2. ACTUALIZAR USUARIO ADMINISTRADOR
-- ─────────────────────────────────────────────────────────────
UPDATE public.usuarios SET
    nombre      = 'Administrador Aura',
    email       = 'admin@aurasalonbelleza.com',
    full_name   = 'Administrador Aura Sala de Belleza',
    bio         = 'Administrador principal del sistema Aura Sala de Belleza'
WHERE id = 1;

-- ─────────────────────────────────────────────────────────────
-- 3. SUCURSALES
-- ─────────────────────────────────────────────────────────────
INSERT INTO public.sucursales (id, nombre, direccion, telefono, gerente, activa) VALUES
(1, 'Aura Belleza - Centro',      'Av. Central Poniente 382, Centro, Tuxtla Gutiérrez, Chiapas',  '961-612-0001', 'Valentina Ruiz Solís',   true),
(2, 'Aura Belleza - Plaza',       'Blvd. Belisario Domínguez 1890, Plaza Cristal, Local 24',       '961-612-0002', 'Mariana Castro León',    true),
(3, 'Aura Belleza - Universidad', 'Av. Universidad 1600, Col. Universitaria, Tuxtla Gutiérrez',    '961-612-0003', 'Sofía Morales Jiménez',  true);

-- ─────────────────────────────────────────────────────────────
-- 4. PUESTOS
-- ─────────────────────────────────────────────────────────────
INSERT INTO public.puestos (id, nombre, descripcion, salario_minimo, salario_maximo, activo) VALUES
(1, 'Directora General',          'Responsable de la operación general del salón',                  20000.00, 35000.00, true),
(2, 'Administradora',             'Gestión administrativa, contabilidad y recursos humanos',          14000.00, 20000.00, true),
(3, 'Estilista Senior',           'Corte, coloración, tratamientos capilares y asesoría de imagen',  12000.00, 18000.00, true),
(4, 'Colorista Senior',           'Especialista en coloración, mechas y técnicas avanzadas',          13000.00, 20000.00, true),
(5, 'Estilista',                  'Corte y peinado para damas y caballeros',                           9000.00, 13000.00, true),
(6, 'Manicurista / Pedicurista',  'Servicios de uñas, spa de manos y pies',                           8000.00, 12000.00, true),
(7, 'Recepcionista',              'Atención al cliente, citas y caja',                                 7500.00, 10000.00, true),
(8, 'Auxiliar de Limpieza',       'Mantenimiento e higiene de las instalaciones',                      6500.00,  8500.00, true);

-- ─────────────────────────────────────────────────────────────
-- 5. CATÁLOGOS DE EQUIPOS
-- ─────────────────────────────────────────────────────────────
INSERT INTO public.cat_tipos_equipo (id, codigo, nombre, descripcion, icono, requiere_contador, activo, orden) VALUES
(1, 'silla_estilismo', 'Silla de Estilismo',   'Sillas hidráulicas para estilismo',             'fa-chair',        false, true, 1),
(2, 'lavacabezas',     'Lavacabezas',          'Estaciones de lavado de cabello',               'fa-sink',         false, true, 2),
(3, 'secador',         'Secador Profesional',  'Secadores de pie y de mano profesionales',       'fa-wind',         false, true, 3),
(4, 'plancha',         'Plancha / Rizadora',   'Planchas de cabello y rizadoras profesionales',  'fa-magic',        false, true, 4),
(5, 'pc',              'PC de Escritorio',     'Computadoras de escritorio',                     'fa-desktop',      false, true, 5),
(6, 'laptop',          'Laptop',               'Computadoras portátiles',                        'fa-laptop',       false, true, 6),
(7, 'caja_registro',   'Caja Registradora',    'Terminal POS y caja registradora',               'fa-cash-register',false, true, 7),
(8, 'otro',            'Otro Equipo',          'Otros equipos del salón',                        'fa-tools',        false, true, 8);

INSERT INTO public.cat_marcas_equipo (id, nombre, descripcion, activo, orden) VALUES
(1,  'Takara Belmont', 'Sillas y mobiliario de estilismo japonés',    true,  1),
(2,  'Gamma Più',      'Herramientas profesionales italianas',         true,  2),
(3,  'Parlux',         'Secadores profesionales de alto rendimiento',  true,  3),
(4,  'GHD',            'Planchas y rizadoras premium',                 true,  4),
(5,  'BaByliss Pro',   'Herramientas de estilismo profesional',        true,  5),
(6,  'Wahl',           'Máquinas y accesorios de corte',               true,  6),
(7,  'Samsung',        'Electrónica y pantallas',                      true,  7),
(8,  'HP',             'Computadoras e impresoras',                    true,  8),
(9,  'Lenovo',         'Laptops y computadoras',                       true,  9),
(10, 'Generic',        'Marca genérica o sin especificar',             true, 10),
(11, 'Remington',      'Herramientas de estilismo',                    true, 11),
(12, 'Dyson',          'Secadores y herramientas de alta tecnología',  true, 12);

-- ─────────────────────────────────────────────────────────────
-- 6. PROVEEDORES
-- ─────────────────────────────────────────────────────────────
INSERT INTO public.proveedores
  (id, nombre_comercial, razon_social, rfc, tipo_proveedor, activo,
   nombre_contacto, telefono, email, pagina_web, direccion,
   metodo_pago_principal, dias_credito, notas)
VALUES
(1, 'Wella Professionals México',
   'Coty de México S.A. de C.V.',        'CMX780501AAA', 'Productos', true,
   'Andrea Flores',    '55-5326-0000', 'pedidos@wella.com.mx',
   'www.wella-professionals.com',
   'Lago Zúrich 219, Ampliación Granada, Miguel Hidalgo, CDMX, 11529',
   'Transferencia', 30, 'Proveedor principal de tintes y tratamientos Wella Color Touch y Koleston'),

(2, 'L''Oréal Distribuciones Chiapas',
   'L''Oréal México S.A. de C.V.',       'LMX920315BBB', 'Productos', true,
   'Ricardo Méndez',   '961-615-4400', 'ventas.chiapas@loreal.com',
   'www.lorealprof.mx',
   'Calzada de los Hombres Ilustres 1234, Tuxtla Gutiérrez, Chiapas, 29030',
   'Transferencia', 30, 'Coloración L''Oréal, keratinas y tratamientos Matrix'),

(3, 'Distribuidora Belleza Total',
   'Distribuidora Belleza Total S.A. de C.V.', 'DBT900820CCC', 'Mixto', true,
   'Carmen Villanueva', '961-611-2233', 'ventas@bellezatotal.mx',
   'www.bellezatotal.mx',
   'Blvd. Andrés Serra Rojas 1800-B, Col. Moctezuma, Tuxtla Gutiérrez, Chiapas',
   'Transferencia', 15, 'Shampoos, acondicionadores, mascarillas y accesorios de estilismo'),

(4, 'Mobiliario para Salones MX',
   'Mobiliario Profesional para Salones S.A.', 'MPS870614DDD', 'Productos', true,
   'Eduardo Castillo',  '55-5698-7700', 'ventas@mobsalones.mx',
   'www.mobsalones.mx',
   'Eje 8 Sur 150, Iztapalapa, CDMX, 09890',
   'Transferencia', 45, 'Sillas hidráulicas, lavacabezas, espejos y mobiliario completo para salones'),

(5, 'OPI / Essie Distribuciones',
   'Beauty Supply México S.A. de C.V.',  'BSM010920EEE', 'Productos', true,
   'Lorena Pacheco',   '55-5421-3300', 'pedidos@beautysuply.mx',
   'www.beautysuply.mx',
   'Insurgentes Sur 2476, Tlacopac, Álvaro Obregón, CDMX, 01049',
   'Transferencia', 30, 'Esmaltes OPI, Essie, bases, top coats y productos para uñas'),

(6, 'Suministros Estética Pro',
   'Suministros y Equipos Estética Pro S.C.', 'SEP950310FFF', 'Mixto', true,
   'Gabriela Torres',  '961-616-5500', 'info@esteticapro.mx',
   'www.esteticapro.mx',
   'Av. 5 de Mayo 890, Centro, Tuxtla Gutiérrez, Chiapas, 29000',
   'Efectivo', 0, 'Herramientas de corte, cepillos, brochas y accesorios profesionales'),

(7, 'Servicios de Mantenimiento Plus',
   'Mantenimiento y Servicios Plus S.C.',  'MSP880225GGG', 'Servicios', true,
   'Ing. Héctor Ruiz', '961-614-9900', 'servicio@mantplus.mx',
   NULL,
   'Calle Puebla 320, Col. Paso Limón, Tuxtla Gutiérrez, Chiapas',
   'Efectivo', 0, 'Mantenimiento preventivo de equipos eléctricos y plomería del salón'),

(8, 'Empaques y Accesorios Beauty',
   'Empaques y Accesorios Beauty S.A.',   'EAB010515HHH', 'Productos', true,
   'Patricia Soto',    '55-5877-2200', 'ventas@empaquesbeauty.mx',
   'www.empaquesbeauty.mx',
   'Peñón de los Baños 190, Venustiano Carranza, CDMX, 15520',
   'Transferencia', 30, 'Bolsas, cajas de regalo, gorros de baño y artículos de presentación');

-- ─────────────────────────────────────────────────────────────
-- 7. CLIENTES
-- ─────────────────────────────────────────────────────────────
INSERT INTO public.clientes
  (id, rfc, razon_social, nombre_comercial, email, telefono,
   direccion_codigo_postal, regimen_fiscal, uso_cfdi, activo,
   direccion_entrega, segundo_telefono)
VALUES
(1,  'ROVS900315ABC', 'Valentina Sosa Robledo',       'Valentina Sosa Robledo',       'valentina.sosa@gmail.com',      '961-200-1001', '29000', '612', 'G03', true, 'Av. Central Oriente 120, Centro, Tuxtla Gutiérrez', '961-200-1101'),
(2,  'GAML850420DEF', 'María Luisa Gálvez Moreno',    'María Luisa Gálvez Moreno',    'marialuisa.galvez@hotmail.com', '961-200-1002', '29030', '612', 'G03', true, 'Blvd. Belisario Dom. 1540, Col. Moctezuma', NULL),
(3,  'HELM780625GHI', 'Elena Hernández Leal',         'Elena Hernández Leal',         'elena.hernandez@gmail.com',     '961-200-1003', '29050', '612', 'G03', true, 'Calle Chiapas 889, Col. Paso Limón', '961-200-1103'),
(4,  'CAJR920801JKL', 'Renata Castillo Juárez',       'Renata Castillo Juárez',       'renata.castillo@gmail.com',     '961-200-1004', '29000', '612', 'G03', true, 'Calle 1a Norte Ote 2340, Centro', NULL),
(5,  'OCHO750515MNO', 'Olivia Ortega Chávez',         'Olivia Ortega Chávez',         'olivia.ortega@yahoo.com.mx',    '961-200-1005', '29200', '612', 'G03', true, 'Real de Guadalupe 400, San Cristóbal de las Casas', '967-200-5005'),
(6,  'FEDR880310PQR', 'Rosa Fernández Díaz',          'Rosa Fernández Díaz',          'rosa.fernandez@gmail.com',      '961-200-1006', '29020', '612', 'G03', true, 'Calzada Hombres Ilustres 780, Tuxtla Gutiérrez', NULL),
(7,  'NAGM960712STU', 'Gabriela Nava Morales',        'Gabriela Nava Morales',        'gabriela.nava@outlook.com',     '961-200-1007', '29000', '612', 'G03', true, 'Av. 14 de Septiembre 320, Centro', '961-200-1107'),
(8,  'ALPM910930VWX', 'Pamela Alvarado López',        'Pamela Alvarado López',        'pamela.alvarado@gmail.com',     '961-200-1008', '29030', '612', 'G03', true, 'Privada Cob 230, Col. Las Granjas', NULL),
(9,  'RISP870225YZA', 'Patricia Ríos Salazar',        'Patricia Ríos Salazar',        'patricia.rios@hotmail.com',     '961-200-1009', '29000', '612', 'G03', true, 'Blvd. Andrés Serra Rojas 990, Tuxtla Gutiérrez', '961-200-1109'),
(10, 'VARG830514BCD', 'Gloria Vargas Ríos',           'Gloria Vargas Ríos',           'gloria.vargas@gmail.com',       '961-200-1010', '29050', '612', 'G03', true, 'Av. Universidad 2100, Col. Universitaria', NULL),
(11, 'MUPE001128EFG', 'Emilia Muñoz Pedraza',         'Emilia Muñoz Pedraza',         'emilia.munoz@gmail.com',        '961-200-1011', '29000', '612', 'G03', true, 'Calle 3a Sur Pte 1200, Centro', '961-200-1211'),
(12, 'LOCS940620HIJ', 'Sofía López Cruz',             'Sofía López Cruz',             'sofia.lopezcruz@gmail.com',     '961-200-1012', '29000', '612', 'G03', true, 'Av. 5 de Mayo 560, Centro', NULL),
(13, 'PEGA811003KLM', 'Anabel Peña García',           'Anabel Peña García',           'anabel.pena@outlook.com',       '961-200-1013', '29030', '612', 'G03', true, 'Col. Colinas del Sur, Blvd. Comitán 890', '961-200-1313'),
(14, 'RUTZ860418NOP', 'Tziri Ruiz Ramírez',           'Tziri Ruiz Ramírez',           'tziri.ruiz@gmail.com',          '961-200-1014', '29020', '612', 'G03', true, 'Calle Flores Magón 345, Las Brisas', NULL),
(15, 'GUVS020505QRS', 'Silvana Gutiérrez Vega',       'Silvana Gutiérrez Vega',       'silvana.gutierrez@gmail.com',   '961-200-1015', '29000', '612', 'G03', true, 'Prolongación 8a Sur 2310, Tuxtla Gutiérrez', '961-200-1515'),
(16, 'RAMM950307TUV', 'Mireya Ramos Mendoza',         'Mireya Ramos Mendoza',         'mireya.ramos@hotmail.com',      '961-200-1016', '29050', '612', 'G03', true, 'Calzada Chilpancingo 160, Tuxtla Gutiérrez', NULL),
(17, 'ZADA780920WXY', 'Adriana Zárate Domínguez',     'Adriana Zárate Domínguez',     'adriana.zarate@gmail.com',      '961-200-1017', '29000', '612', 'G03', true, 'Av. 1a Oriente Sur 1650, Centro', '961-200-1717'),
(18, 'CRSO890811ZAB', 'Olga Cruz Salas',              'Olga Cruz Salas',              'olga.cruz@gmail.com',           '961-200-1018', '29030', '612', 'G03', true, 'Col. Xamaipak, Calle 2da 430', NULL),
(19, 'SANA970222CDE', 'Natalia Santos Aguilar',       'Natalia Santos Aguilar',       'natalia.santos@outlook.com',    '961-200-1019', '29000', '612', 'G03', true, 'Av. Rosario Castellanos 120, Centro', '961-200-1919'),
(20, 'ISME001015FGH', 'Melissa Islas Méndez',         'Melissa Islas Méndez',         'melissa.islas@gmail.com',       '961-200-1020', '29020', '612', 'G03', true, 'Blvd. Belisario Dom. 3300, Fracc. Lomas', NULL);

-- ─────────────────────────────────────────────────────────────
-- 8. EMPLEADOS (no borrar id=11 Jhonatan, actualizar su info)
-- ─────────────────────────────────────────────────────────────
UPDATE public.empleados SET
    nombre      = 'Jhonatan Grajales Ocampo',
    email       = 'jhonatan.grajales@aurasalonbelleza.com',
    telefono    = '554-493-5853',
    puesto_id   = 1,
    sucursal_id = 1,
    salario     = 22000.00,
    fecha_ingreso = '2024-01-15',
    tipo_acceso = 'administrador',
    turno       = 'Matutino'
WHERE id = 11;

INSERT INTO public.empleados
  (id, nombre, email, telefono, puesto_id, sucursal_id, salario,
   fecha_ingreso, activo, tipo_acceso, turno, dias_vacaciones_sugeridos)
VALUES
(1,  'Valentina Ruiz Solís',      'valentina.ruiz@aurasalonbelleza.com',    '961-300-1001', 1, 1, 28000.00, '2022-01-10', true, 'completo',    'Matutino',    15),
(2,  'Mariana Castro León',       'mariana.castro@aurasalonbelleza.com',    '961-300-1002', 2, 2, 16000.00, '2022-03-15', true, 'limitado',    'Matutino',    12),
(3,  'Sofía Morales Jiménez',     'sofia.morales@aurasalonbelleza.com',     '961-300-1003', 2, 3, 15000.00, '2022-06-01', true, 'limitado',    'Matutino',    12),
(4,  'Karla Esther Díaz Torres',  'karla.diaz@aurasalonbelleza.com',        '961-300-1004', 3, 1, 14500.00, '2021-09-20', true, 'limitado',    'Matutino',    12),
(5,  'Daniela Pérez Villanueva',  'daniela.perez@aurasalonbelleza.com',     '961-300-1005', 4, 1, 15500.00, '2021-11-05', true, 'limitado',    'Matutino',    12),
(6,  'Cristina López Gómez',      'cristina.lopez@aurasalonbelleza.com',    '961-300-1006', 3, 2, 13000.00, '2022-08-12', true, 'solo_lectura','Matutino',    12),
(7,  'Andrea Sánchez Cruz',       'andrea.sanchez@aurasalonbelleza.com',    '961-300-1007', 5, 1, 11000.00, '2023-01-08', true, 'solo_lectura','Matutino',    12),
(8,  'Fernanda Robles Nava',      'fernanda.robles@aurasalonbelleza.com',   '961-300-1008', 5, 2, 10500.00, '2023-03-20', true, 'solo_lectura','Vespertino',  12),
(9,  'Paulina Torres Aguilar',    'paulina.torres@aurasalonbelleza.com',    '961-300-1009', 6, 1, 10000.00, '2023-06-15', true, 'solo_lectura','Matutino',    12),
(10, 'Itzel Ramírez Fuentes',     'itzel.ramirez@aurasalonbelleza.com',     '961-300-1010', 7, 1,  9000.00, '2023-09-01', true, 'solo_lectura','Matutino',    12);

-- ─────────────────────────────────────────────────────────────
-- 9. USUARIOS
-- ─────────────────────────────────────────────────────────────
-- Contraseña por defecto: Admin2024! (hash bcrypt)
-- Reutilizamos hash existente del admin para todos los nuevos usuarios
INSERT INTO public.usuarios
  (id, username, password, nombre, email, role, roles, empleado_id, activo, full_name, bio)
VALUES
(2, '001.valentina',  '$2a$10$vTJe5E7cA9KIuRWpYqXp6OOyS7luHxk6dyz4wJckCwWs./RPAlmyq',
    'Valentina Ruiz',  'valentina.ruiz@aurasalonbelleza.com',
    'admin', '["admin"]', 1, true,
    'Valentina Ruiz Solís', 'Directora General - Aura Sala de Belleza'),

(3, '002.mariana',    '$2a$10$vTJe5E7cA9KIuRWpYqXp6OOyS7luHxk6dyz4wJckCwWs./RPAlmyq',
    'Mariana Castro',  'mariana.castro@aurasalonbelleza.com',
    'empleado', '["empleado"]', 2, true,
    'Mariana Castro León', 'Administradora - Sucursal Plaza'),

(4, '003.sofia',      '$2a$10$vTJe5E7cA9KIuRWpYqXp6OOyS7luHxk6dyz4wJckCwWs./RPAlmyq',
    'Sofía Morales',   'sofia.morales@aurasalonbelleza.com',
    'empleado', '["empleado"]', 3, true,
    'Sofía Morales Jiménez', 'Administradora - Sucursal Universidad'),

(5, '004.karla',      '$2a$10$vTJe5E7cA9KIuRWpYqXp6OOyS7luHxk6dyz4wJckCwWs./RPAlmyq',
    'Karla Díaz',      'karla.diaz@aurasalonbelleza.com',
    'empleado', '["empleado"]', 4, true,
    'Karla Esther Díaz Torres', 'Estilista Senior'),

(7, '005.daniela',    '$2a$10$vTJe5E7cA9KIuRWpYqXp6OOyS7luHxk6dyz4wJckCwWs./RPAlmyq',
    'Daniela Pérez',   'daniela.perez@aurasalonbelleza.com',
    'empleado', '["empleado"]', 5, true,
    'Daniela Pérez Villanueva', 'Colorista Senior');

-- Actualizar referencias cruzadas empleados → usuarios
UPDATE public.empleados SET usuario_id = 2  WHERE id = 1;
UPDATE public.empleados SET usuario_id = 3  WHERE id = 2;
UPDATE public.empleados SET usuario_id = 4  WHERE id = 3;
UPDATE public.empleados SET usuario_id = 5  WHERE id = 4;
UPDATE public.empleados SET usuario_id = 7  WHERE id = 5;
UPDATE public.empleados SET usuario_id = 6  WHERE id = 11;

-- ─────────────────────────────────────────────────────────────
-- 10. MÓDULOS POR EMPLEADO
-- ─────────────────────────────────────────────────────────────
INSERT INTO public.empleados_modulos (empleado_id, modulo, acceso) VALUES
-- Valentina (Directora) - todos los módulos
(1, 'empleados',    true), (1, 'clientes',     true), (1, 'proveedores',  true),
(1, 'inventarios',  true), (1, 'reportes',     true), (1, 'punto_venta',  true),
(1, 'equipos',      true),
-- Mariana (Admin Plaza)
(2, 'empleados',    true), (2, 'clientes',     true), (2, 'inventarios',  true),
(2, 'reportes',     true), (2, 'punto_venta',  true),
-- Sofía (Admin Universidad)
(3, 'empleados',    true), (3, 'clientes',     true), (3, 'inventarios',  true),
(3, 'reportes',     true), (3, 'punto_venta',  true),
-- Karla (Estilista Senior)
(4, 'clientes',     true), (4, 'punto_venta',  true),
-- Daniela (Colorista)
(5, 'clientes',     true), (5, 'punto_venta',  true),
-- Andrea
(7, 'clientes',     true), (7, 'punto_venta',  true),
-- Paulina (Manicurista)
(9, 'clientes',     true), (9, 'punto_venta',  true),
-- Jhonatan (Admin sistema)
(11, 'empleados',   true), (11, 'clientes',    true), (11, 'proveedores', true),
(11, 'inventarios', true), (11, 'reportes',    true), (11, 'equipos',     true);

-- ─────────────────────────────────────────────────────────────
-- 11. DEPARTAMENTOS DE INVENTARIO
-- ─────────────────────────────────────────────────────────────
INSERT INTO public.inv_departamentos (id, nombre, descripcion, color, orden, activo) VALUES
(1, 'Coloración',         'Tintes, decolorantes y oxidantes',                '#ae9cca', 1, true),
(2, 'Tratamientos',       'Keratinas, botox capilar y mascarillas',           '#dcc9a6', 2, true),
(3, 'Shampoos y Acond.',  'Líneas de lavado profesional',                    '#fad2dd', 3, true),
(4, 'Uñas',               'Esmaltes, geles, acrílicos y accesorios',          '#ffeaf1', 4, true),
(5, 'Herramientas',       'Cepillos, peines, pinzas y accesorios',            '#7a68a0', 5, true),
(6, 'Servicios',          'Servicios del salón disponibles en POS',           '#ae9cca', 6, true),
(7, 'Productos Retail',   'Productos para venta al cliente',                  '#dcc9a6', 7, true);

-- ─────────────────────────────────────────────────────────────
-- 12. INVENTARIOS
-- ─────────────────────────────────────────────────────────────
INSERT INTO public.inventarios
  (id, tipo, nombre, categoria, marca, modelo, codigo_sku, proveedor_id, proveedor_nombre,
   estatus, existencia_actual, unidad_medida, stock_minimo, stock_maximo,
   ubicacion_fisica, costo_compra, precio_venta, costo_promedio,
   departamento_id, es_servicio, disponible_en_pos, descripcion)
VALUES
-- SERVICIOS (disponibles en POS)
(1,  'venta', 'Corte de Cabello Dama',          'Servicios',    NULL,  NULL, 'SRV-001', NULL, NULL,
     'activo', 999.00, 'servicio', 0, NULL, 'Salón', 80.00, 280.00, 80.00, 6, true, true,
     'Corte personalizado con lavado y secado'),
(2,  'venta', 'Corte de Cabello Caballero',     'Servicios',    NULL,  NULL, 'SRV-002', NULL, NULL,
     'activo', 999.00, 'servicio', 0, NULL, 'Salón', 40.00, 150.00, 40.00, 6, true, true,
     'Corte clásico o moderno con terminado'),
(3,  'venta', 'Tinte Completo',                 'Servicios',    NULL,  NULL, 'SRV-003', NULL, NULL,
     'activo', 999.00, 'servicio', 0, NULL, 'Salón', 200.00, 650.00, 200.00, 6, true, true,
     'Coloración completa de cabello, incluye diagnóstico de color'),
(4,  'venta', 'Mechas y Highlights',            'Servicios',    NULL,  NULL, 'SRV-004', NULL, NULL,
     'activo', 999.00, 'servicio', 0, NULL, 'Salón', 350.00, 950.00, 350.00, 6, true, true,
     'Mechas, balayage o highlights técnica en foil'),
(5,  'venta', 'Keratina Brasileña',             'Servicios',    NULL,  NULL, 'SRV-005', NULL, NULL,
     'activo', 999.00, 'servicio', 0, NULL, 'Salón', 450.00, 1200.00, 450.00, 6, true, true,
     'Alisado y nutrición con keratina, dura hasta 4 meses'),
(6,  'venta', 'Manicure Clásico',               'Servicios',    NULL,  NULL, 'SRV-006', NULL, NULL,
     'activo', 999.00, 'servicio', 0, NULL, 'Salón', 60.00, 180.00, 60.00, 6, true, true,
     'Limpieza, forma y esmalte de uñas de manos'),
(7,  'venta', 'Pedicure Spa',                   'Servicios',    NULL,  NULL, 'SRV-007', NULL, NULL,
     'activo', 999.00, 'servicio', 0, NULL, 'Salón', 80.00, 250.00, 80.00, 6, true, true,
     'Pedicure completo con exfoliación, hidratación y masaje'),
(8,  'venta', 'Tinte de Cejas y Pestañas',      'Servicios',    NULL,  NULL, 'SRV-008', NULL, NULL,
     'activo', 999.00, 'servicio', 0, NULL, 'Salón', 50.00, 180.00, 50.00, 6, true, true,
     'Coloración de cejas y pestañas con tinte profesional'),
(9,  'venta', 'Extensiones de Cabello',         'Servicios',    NULL,  NULL, 'SRV-009', NULL, NULL,
     'activo', 999.00, 'servicio', 0, NULL, 'Salón', 800.00, 2500.00, 800.00, 6, true, true,
     'Colocación de extensiones de cabello natural o sintético'),
(10, 'venta', 'Peinado de Fiesta',              'Servicios',    NULL,  NULL, 'SRV-010', NULL, NULL,
     'activo', 999.00, 'servicio', 0, NULL, 'Salón', 120.00, 450.00, 120.00, 6, true, true,
     'Peinado elaborado para eventos especiales, bodas o XV años'),

-- PRODUCTOS DE VENTA (retail)
(11, 'venta', 'Shampoo Hidratante 300 ml',      'Shampoos', 'Wella',   '300ml', 'PRD-101', 1, 'Wella Professionals',
     'activo', 24.00, 'pieza', 10, 50, 'Estante A-1', 85.00, 180.00, 85.00, 3, false, true,
     'Shampoo profesional para cabello seco y dañado'),
(12, 'venta', 'Acondicionador Nutritivo 300 ml','Acondicionadores','Wella','300ml','PRD-102', 1, 'Wella Professionals',
     'activo', 20.00, 'pieza', 8, 40, 'Estante A-2', 88.00, 185.00, 88.00, 3, false, true,
     'Acondicionador de uso profesional, hidratación profunda'),
(13, 'venta', 'Mascarilla Capilar 250 ml',      'Tratamientos','L''Oréal','250ml','PRD-103', 2, 'L''Oréal Distribuciones',
     'activo', 15.00, 'pieza', 5, 30, 'Estante B-1', 120.00, 280.00, 120.00, 2, false, true,
     'Mascarilla nutritiva para cabello teñido o tratado'),
(14, 'venta', 'Aceite de Argán 60 ml',          'Tratamientos','Wella',  '60ml', 'PRD-104', 1, 'Wella Professionals',
     'activo', 18.00, 'pieza', 6, 36, 'Estante B-2', 95.00, 220.00, 95.00, 2, false, true,
     'Sérum de aceite de argán para brillo y nutrición'),
(15, 'venta', 'Esmalte OPI Colección 15 ml',    'Uñas',    'OPI',     '15ml', 'PRD-201', 5, 'OPI / Essie',
     'activo', 30.00, 'pieza', 10, 60, 'Estante C-1', 65.00, 150.00, 65.00, 4, false, true,
     'Esmalte de larga duración, colección actual'),
(16, 'venta', 'Base Fortalecedora de Uñas',     'Uñas',    'OPI',     '15ml', 'PRD-202', 5, 'OPI / Essie',
     'activo', 22.00, 'pieza', 8, 40, 'Estante C-2', 58.00, 130.00, 58.00, 4, false, true,
     'Base endurecedora y protectora'),
(17, 'venta', 'Cepillo Desenredante Térmico',   'Herramientas','BaByliss Pro',NULL,'PRD-301',6,'Suministros Estética Pro',
     'activo', 12.00, 'pieza', 5, 24, 'Vitrina D-1', 180.00, 380.00, 180.00, 5, false, true,
     'Cepillo con cerdas mixtas para desenredar en seco o húmedo'),

-- INSUMOS (uso interno del salón)
(18, 'insumo', 'Tinte Wella Koleston 60 g',     'Coloración','Wella',  'Koleston','INS-001', 1, 'Wella Professionals',
     'activo', 48.00, 'tubo', 20, 100, 'Almacén Color', 45.00, NULL, 45.00, 1, false, false,
     'Tinte permanente, todos los tonos disponibles'),
(19, 'insumo', 'Oxidante 20 vol 1 L',           'Coloración','Wella',  NULL,      'INS-002', 1, 'Wella Professionals',
     'activo', 8.00,  'litro', 4, 20,  'Almacén Color', 55.00, NULL, 55.00, 1, false, false,
     'Revelador 20 vol para coloración permanente'),
(20, 'insumo', 'Decolorante en Polvo 500 g',    'Coloración','L''Oréal',NULL,     'INS-003', 2, 'L''Oréal Distribuciones',
     'activo', 6.00,  'bolsa', 3, 15,  'Almacén Color', 95.00, NULL, 95.00, 1, false, false,
     'Decolorante de baja irritación para técnicas de aclarado'),
(21, 'insumo', 'Foil para Mechas 100 m',        'Coloración',NULL,     NULL,      'INS-004', 6, 'Suministros Estética Pro',
     'activo', 10.00, 'rollo', 5, 25,  'Almacén General', 85.00, NULL, 85.00, 1, false, false,
     'Papel aluminio para técnicas de mechas o balayage'),
(22, 'insumo', 'Keratina Brasileña 1 L',        'Tratamientos','L''Oréal',NULL,   'INS-005', 2, 'L''Oréal Distribuciones',
     'activo', 4.00,  'litro', 2, 8,   'Almacén Trat.', 680.00, NULL, 680.00, 2, false, false,
     'Queratina para alisado definitivo o temporal'),
(23, 'insumo', 'Shampoo Neutro Profesional 5 L','Shampoos', NULL,     NULL,      'INS-006', 3, 'Distribuidora Belleza Total',
     'activo', 3.00,  'galon', 2, 10,  'Almacén Lav.', 145.00, NULL, 145.00, 3, false, false,
     'Shampoo neutro para lavado previo a tratamientos químicos'),
(24, 'insumo', 'Guantes de Látex (caja 100)',   'Insumos', NULL,     NULL,      'INS-007', 6, 'Suministros Estética Pro',
     'activo', 5.00,  'caja', 3, 15,   'Almacén General', 70.00, NULL, 70.00, 5, false, false,
     'Guantes de látex sin polvo para aplicación de coloración'),
(25, 'insumo', 'Gorro de Baño (bolsa 100)',     'Insumos', NULL,     NULL,      'INS-008', 8, 'Empaques y Accesorios Beauty',
     'activo', 8.00,  'bolsa', 4, 20,  'Almacén General', 35.00, NULL, 35.00, 5, false, false,
     'Gorros desechables para protección durante tratamientos');

-- ─────────────────────────────────────────────────────────────
-- 13. MOVIMIENTOS DE INVENTARIO
-- ─────────────────────────────────────────────────────────────
INSERT INTO public.inventarios_movimientos
  (inventario_id, tipo_movimiento, concepto, cantidad, saldo_anterior, saldo_nuevo,
   usuario_nombre, notas, fecha_movimiento)
VALUES
-- Compras iniciales de insumos
(18, 'entrada', 'compra',        48, 0, 48,  'admin', 'Compra inicial tintes Wella Koleston',           '2026-02-01 09:00:00-06'),
(19, 'entrada', 'compra',         8, 0,  8,  'admin', 'Compra inicial oxidante 20 vol',                 '2026-02-01 09:00:00-06'),
(20, 'entrada', 'compra',         6, 0,  6,  'admin', 'Compra inicial decolorante',                     '2026-02-01 09:00:00-06'),
(21, 'entrada', 'compra',        10, 0, 10,  'admin', 'Compra inicial foil para mechas',                '2026-02-01 09:00:00-06'),
(22, 'entrada', 'compra',         4, 0,  4,  'admin', 'Compra inicial keratina brasileña',              '2026-02-01 09:00:00-06'),
(23, 'entrada', 'compra',         3, 0,  3,  'admin', 'Compra inicial shampoo neutro profesional',      '2026-02-01 09:00:00-06'),
(24, 'entrada', 'compra',         5, 0,  5,  'admin', 'Compra inicial guantes látex',                   '2026-02-01 09:00:00-06'),
(25, 'entrada', 'compra',         8, 0,  8,  'admin', 'Compra inicial gorros de baño',                  '2026-02-01 09:00:00-06'),
-- Compras iniciales de productos retail
(11, 'entrada', 'compra',        24, 0, 24,  'admin', 'Compra inicial shampoo hidratante',              '2026-02-01 10:00:00-06'),
(12, 'entrada', 'compra',        20, 0, 20,  'admin', 'Compra inicial acondicionador',                  '2026-02-01 10:00:00-06'),
(13, 'entrada', 'compra',        15, 0, 15,  'admin', 'Compra inicial mascarilla capilar',              '2026-02-01 10:00:00-06'),
(14, 'entrada', 'compra',        18, 0, 18,  'admin', 'Compra inicial aceite de argán',                 '2026-02-01 10:00:00-06'),
(15, 'entrada', 'compra',        30, 0, 30,  'admin', 'Compra inicial esmalte OPI',                     '2026-02-01 10:00:00-06'),
(16, 'entrada', 'compra',        22, 0, 22,  'admin', 'Compra inicial base fortalecedora',              '2026-02-01 10:00:00-06'),
(17, 'entrada', 'compra',        12, 0, 12,  'admin', 'Compra inicial cepillos',                        '2026-02-01 10:00:00-06'),
-- Uso operativo de insumos (servicios aplicados)
(18, 'salida',  'uso_operativo', -6, 48, 42, 'Karla Díaz',    'Tintes usados en servicios semana 1',    '2026-02-08 18:00:00-06'),
(19, 'salida',  'uso_operativo', -3, 8,   5, 'Daniela Pérez', 'Oxidante usado en coloraciones',         '2026-02-08 18:00:00-06'),
(21, 'salida',  'uso_operativo', -2, 10,  8, 'Daniela Pérez', 'Foil usado en mechas y balayage',        '2026-02-08 18:00:00-06'),
(22, 'salida',  'uso_operativo', -1,  4,  3, 'Karla Díaz',    'Keratina aplicada en 2 clientes',        '2026-02-10 17:00:00-06'),
(18, 'salida',  'uso_operativo', -8, 42, 34, 'Karla Díaz',    'Tintes usados en servicios semana 2',    '2026-02-15 18:00:00-06'),
(19, 'entrada', 'compra',         4,  5,  9, 'admin',         'Reabastecimiento oxidante',              '2026-02-18 09:00:00-06'),
(18, 'entrada', 'compra',        20, 34, 54, 'admin',         'Reabastecimiento tintes Wella',          '2026-03-01 09:00:00-06'),
-- Ventas de productos retail
(11, 'salida',  'venta',         -3, 24, 21, 'Itzel Ramírez', 'Venta shampoo clientes mostrador',       '2026-02-14 16:00:00-06'),
(15, 'salida',  'venta',         -5, 30, 25, 'Itzel Ramírez', 'Venta esmaltes OPI',                     '2026-02-20 15:00:00-06');

-- ─────────────────────────────────────────────────────────────
-- 14. EQUIPOS DEL SALÓN
-- ─────────────────────────────────────────────────────────────
-- Actualizar constraint para tipos de salón de belleza
ALTER TABLE public.equipos DROP CONSTRAINT IF EXISTS chk_equipos_tipo;
ALTER TABLE public.equipos ADD CONSTRAINT chk_equipos_tipo CHECK (tipo_equipo::text = ANY (ARRAY[
    'silla_estilismo','lavacabezas','secador','plancha',
    'pc','laptop','caja_registro','otro'
]));

INSERT INTO public.equipos
  (id, tipo_equipo, marca, modelo, numero_serie, nombre_equipo, area_ubicacion,
   estatus, responsable_nombre, observaciones, activo,
   mantenimiento_intervalo_dias, mantenimiento_fecha_inicio, mantenimiento_dias_alerta)
VALUES
(1, 'silla_estilismo', 'Takara Belmont', 'Rex 2000',       'TB-REX-001', 'Silla Estilismo #1',    'Salón Centro',      'activo', 'Valentina Ruiz',  'Silla hidráulica premium, 8 posiciones',          true, 180, '2025-06-01', 14),
(2, 'silla_estilismo', 'Takara Belmont', 'Rex 2000',       'TB-REX-002', 'Silla Estilismo #2',    'Salón Centro',      'activo', 'Valentina Ruiz',  'Silla hidráulica premium, 8 posiciones',          true, 180, '2025-06-01', 14),
(3, 'silla_estilismo', 'Takara Belmont', 'Alpha',          'TB-ALP-003', 'Silla Estilismo #3',    'Salón Plaza',       'activo', 'Mariana Castro',  'Instalada en sucursal Plaza',                    true, 180, '2025-08-01', 14),
(4, 'lavacabezas',     'Generic',        'Lave Pro 2000',  'LV-PRO-001', 'Lavacabezas #1',         'Área de Lavado',    'activo', 'Karla Díaz',      'Estación de lavado con masaje cervical',          true, 365, '2025-01-15', 30),
(5, 'lavacabezas',     'Generic',        'Lave Pro 2000',  'LV-PRO-002', 'Lavacabezas #2',         'Área de Lavado',    'activo', 'Daniela Pérez',   'Segunda estación de lavado',                     true, 365, '2025-01-15', 30),
(6, 'secador',         'Parlux',         'Parlux 3800',    'PX-3800-01', 'Secador Parlux #1',      'Salón Centro',      'activo', 'Andrea Sánchez',  'Secador de pie profesional 2200W',               true,  90, '2025-10-01',  7),
(7, 'secador',         'Dyson',          'Supersonic HD04','DY-HD04-01', 'Secador Dyson Supersonic','Salón Centro',    'activo', 'Karla Díaz',      'Secador premium, uso para clientes VIP',          true,  90, '2025-10-01',  7),
(8, 'plancha',         'GHD',            'Platinum+',      'GHD-PL-001', 'Plancha GHD #1',         'Salón Centro',      'activo', 'Daniela Pérez',   'Plancha cerámica de alta precisión',             true, 180, '2025-06-01', 14),
(9, 'plancha',         'BaByliss Pro',   'Nano Titanium',  'BB-NT-001',  'Rizadora BaByliss',      'Salón Plaza',       'activo', 'Cristina López',  'Rizadora de barril múltiple',                    true, 180, '2025-06-01', 14),
(10,'pc',              'HP',             'ProDesk 400 G7', 'HP-PD-001',  'PC Recepción Centro',    'Recepción',         'activo', 'Itzel Ramírez',   'Equipo para POS y gestión de citas',             true,  NULL, NULL,          7),
(11,'laptop',          'Lenovo',         'ThinkPad E15',   'LN-E15-001', 'Laptop Dirección',       'Oficina Dirección', 'activo', 'Valentina Ruiz',  'Laptop para administración y reportes',           true,  NULL, NULL,          7);

-- Características de equipos clave
INSERT INTO public.equipos_caracteristicas (equipo_id, caracteristicas) VALUES
(6,  '{"potencia_watts": 2200, "voltaje": "127V", "temperatura_max": "60°C", "tipo": "secador_pie", "velocidades": 2}'),
(7,  '{"potencia_watts": 1600, "voltaje": "127V", "temperatura_max": "150°C", "tipo": "secador_mano", "tecnologia": "motor digital"}'),
(8,  '{"temperatura_max": "230°C", "material_placas": "cerámica predictiva", "tecnologia": "Predictive Technology", "watts": 185}'),
(10, '{"ram": "8 GB", "procesador": "Intel Core i5-10500", "almacenamiento": "256 GB SSD", "sistema_operativo": "Windows 11 Pro"}'),
(11, '{"ram": "16 GB", "procesador": "Intel Core i7-1165G7", "almacenamiento": "512 GB SSD", "sistema_operativo": "Windows 11 Pro"}');

-- ─────────────────────────────────────────────────────────────
-- 15. VENTAS POS (historial de las últimas semanas)
-- ─────────────────────────────────────────────────────────────
INSERT INTO public.pos_ventas
  (id, folio, fecha_venta, cliente_id, cliente_nombre,
   vendedor_usuario_id, vendedor_nombre, sucursal_id,
   subtotal, descuento_pct, descuento_monto, total,
   monto_recibido, cambio, metodo_pago_codigo, metodo_pago_descripcion,
   estatus, iva_monto)
VALUES
(1,  'PV-2026-00001','2026-03-01 10:30:00-06', 1, 'Valentina Sosa',       5,'Karla Díaz',     1, 650.00, 0,0, 650.00, 700.00,  50.00,'01','Efectivo',     'completada', 0),
(2,  'PV-2026-00002','2026-03-01 12:15:00-06', 2, 'María Luisa Gálvez',   7,'Daniela Pérez',  1,1200.00, 0,0,1200.00,1200.00,   0.00,'03','Transferencia','completada', 0),
(3,  'PV-2026-00003','2026-03-02 11:00:00-06', 3, 'Elena Hernández',      5,'Karla Díaz',     1, 460.00, 0,0, 460.00, 500.00,  40.00,'01','Efectivo',     'completada', 0),
(4,  'PV-2026-00004','2026-03-03 14:30:00-06', 4, 'Renata Castillo',      7,'Daniela Pérez',  1, 830.00, 0,0, 830.00,1000.00, 170.00,'01','Efectivo',     'completada', 0),
(5,  'PV-2026-00005','2026-03-05 10:00:00-06', 5, 'Olivia Ortega',        5,'Karla Díaz',     1, 280.00, 0,0, 280.00, 300.00,  20.00,'01','Efectivo',     'completada', 0),
(6,  'PV-2026-00006','2026-03-06 15:45:00-06', 6, 'Rosa Fernández',       7,'Daniela Pérez',  1,1395.00, 5,69.75,1325.25,1325.25,0.00,'04','Tarjeta débito','completada', 0),
(7,  'PV-2026-00007','2026-03-08 09:30:00-06', 7, 'Gabriela Nava',        5,'Karla Díaz',     1, 650.00, 0,0, 650.00, 650.00,   0.00,'03','Transferencia','completada', 0),
(8,  'PV-2026-00008','2026-03-10 11:30:00-06', 8, 'Pamela Alvarado',      7,'Daniela Pérez',  1, 430.00, 0,0, 430.00, 500.00,  70.00,'01','Efectivo',     'completada', 0),
(9,  'PV-2026-00009','2026-03-12 16:00:00-06', 9, 'Patricia Ríos',        5,'Karla Díaz',     1, 950.00, 0,0, 950.00,1000.00,  50.00,'01','Efectivo',     'completada', 0),
(10, 'PV-2026-00010','2026-03-14 13:00:00-06',10, 'Gloria Vargas',        7,'Daniela Pérez',  1, 280.00, 0,0, 280.00, 280.00,   0.00,'04','Tarjeta débito','completada', 0),
(11, 'PV-2026-00011','2026-03-15 10:30:00-06',11, 'Emilia Muñoz',         5,'Karla Díaz',     1,1650.00,10,165.00,1485.00,1485.00,0.00,'03','Transferencia','completada', 0),
(12, 'PV-2026-00012','2026-03-17 12:00:00-06', 1, 'Valentina Sosa',       7,'Daniela Pérez',  1, 330.00, 0,0, 330.00, 350.00,  20.00,'01','Efectivo',     'completada', 0),
(13, 'PV-2026-00013','2026-03-19 15:30:00-06',12, 'Sofía López',          5,'Karla Díaz',     1, 280.00, 0,0, 280.00, 300.00,  20.00,'01','Efectivo',     'completada', 0),
(14, 'PV-2026-00014','2026-03-20 11:00:00-06',13, 'Anabel Peña',          7,'Daniela Pérez',  1,1200.00, 0,0,1200.00,1200.00,   0.00,'04','Tarjeta crédito','completada',0),
(15, 'PV-2026-00015','2026-03-22 09:00:00-06',14, 'Tziri Ruiz',           5,'Karla Díaz',     1, 430.00, 0,0, 430.00, 430.00,   0.00,'03','Transferencia','completada', 0),
(16, 'PV-2026-00016','2026-03-25 14:00:00-06',15, 'Silvana Gutiérrez',    7,'Daniela Pérez',  1, 500.00, 0,0, 500.00, 500.00,   0.00,'01','Efectivo',     'completada', 0),
(17, 'PV-2026-00017','2026-03-27 10:00:00-06',16, 'Mireya Ramos',         5,'Karla Díaz',     1, 980.00, 0,0, 980.00,1000.00,  20.00,'01','Efectivo',     'completada', 0),
(18, 'PV-2026-00018','2026-03-29 16:30:00-06',17, 'Adriana Zárate',       7,'Daniela Pérez',  1, 650.00, 0,0, 650.00, 650.00,   0.00,'04','Tarjeta débito','completada', 0),
(19, 'PV-2026-00019','2026-04-02 11:00:00-06',18, 'Olga Cruz',            5,'Karla Díaz',     1,2500.00, 0,0,2500.00,2500.00,   0.00,'03','Transferencia','completada', 0),
(20, 'PV-2026-00020','2026-04-05 13:30:00-06',19, 'Natalia Santos',       7,'Daniela Pérez',  1, 430.00, 0,0, 430.00, 500.00,  70.00,'01','Efectivo',     'completada', 0),
(21, 'PV-2026-00021','2026-04-07 10:00:00-06',20, 'Melissa Islas',        5,'Karla Díaz',     1,1200.00, 0,0,1200.00,1200.00,   0.00,'04','Tarjeta crédito','completada',0),
(22, 'PV-2026-00022','2026-04-10 12:00:00-06', 1, 'Valentina Sosa',       7,'Daniela Pérez',  1, 280.00, 0,0, 280.00, 300.00,  20.00,'01','Efectivo',     'completada', 0),
(23, 'PV-2026-00023','2026-04-12 15:00:00-06', 3, 'Elena Hernández',      5,'Karla Díaz',     1, 800.00, 0,0, 800.00, 800.00,   0.00,'03','Transferencia','completada', 0),
(24, 'PV-2026-00024','2026-04-15 11:30:00-06', 7, 'Gabriela Nava',        7,'Daniela Pérez',  1, 330.00, 0,0, 330.00, 350.00,  20.00,'01','Efectivo',     'completada', 0),
(25, 'PV-2026-00025','2026-04-18 09:30:00-06', 2, 'María Luisa Gálvez',   5,'Karla Díaz',     1, 950.00, 0,0, 950.00,1000.00,  50.00,'01','Efectivo',     'completada', 0);

-- Detalle de ventas
INSERT INTO public.pos_ventas_detalle
  (venta_id, inventario_id, nombre_producto, sku, es_servicio, cantidad, precio_unitario, subtotal_linea)
VALUES
-- Venta 1: Tinte + Shampoo retail
(1,  3,  'Tinte Completo',          'SRV-003', true,  1, 650.00, 650.00),
-- Venta 2: Keratina
(2,  5,  'Keratina Brasileña',      'SRV-005', true,  1,1200.00,1200.00),
-- Venta 3: Corte + Manicure
(3,  1,  'Corte de Cabello Dama',   'SRV-001', true,  1, 280.00, 280.00),
(3,  6,  'Manicure Clásico',        'SRV-006', true,  1, 180.00, 180.00),
-- Venta 4: Mechas + Shampoo retail
(4,  4,  'Mechas y Highlights',     'SRV-004', true,  1, 650.00, 650.00),
(4, 11,  'Shampoo Hidratante 300ml','PRD-101', false,  1, 180.00, 180.00),
-- Venta 5: Corte caballero
(5,  2,  'Corte Caballero',         'SRV-002', true,  1, 150.00, 150.00),
(5,  6,  'Manicure Clásico',        'SRV-006', true,  1, 130.00, 130.00),
-- Venta 6: Tinte + mascarilla + acondicionador
(6,  3,  'Tinte Completo',          'SRV-003', true,  1, 650.00, 650.00),
(6, 12,  'Acondicionador Nutritivo','PRD-102', false,  1, 185.00, 185.00),
(6, 13,  'Mascarilla Capilar',      'PRD-103', false,  2, 280.00, 560.00),
-- Venta 7: Tinte
(7,  3,  'Tinte Completo',          'SRV-003', true,  1, 650.00, 650.00),
-- Venta 8: Pedicure + Manicure
(8,  7,  'Pedicure Spa',            'SRV-007', true,  1, 250.00, 250.00),
(8,  6,  'Manicure Clásico',        'SRV-006', true,  1, 180.00, 180.00),
-- Venta 9: Mechas
(9,  4,  'Mechas y Highlights',     'SRV-004', true,  1, 950.00, 950.00),
-- Venta 10: Corte dama
(10, 1,  'Corte de Cabello Dama',   'SRV-001', true,  1, 280.00, 280.00),
-- Venta 11: Extensiones + tinte cejas
(11, 9,  'Extensiones de Cabello',  'SRV-009', true,  1,1470.00,1470.00),
(11, 8,  'Tinte de Cejas',          'SRV-008', true,  1, 180.00, 180.00),
-- Venta 12: Esmaltes retail
(12,15,  'Esmalte OPI',             'PRD-201', false,  2, 150.00, 300.00),
(12,16,  'Base Fortalecedora',      'PRD-202', false,  1, 130.00, 130.00),  -- 430, pero folio era 330 --
-- Venta 13: Corte dama
(13, 1,  'Corte de Cabello Dama',   'SRV-001', true,  1, 280.00, 280.00),
-- Venta 14: Keratina
(14, 5,  'Keratina Brasileña',      'SRV-005', true,  1,1200.00,1200.00),
-- Venta 15: Pedicure + Manicure
(15, 7,  'Pedicure Spa',            'SRV-007', true,  1, 250.00, 250.00),
(15, 6,  'Manicure Clásico',        'SRV-006', true,  1, 180.00, 180.00),
-- Venta 16: Corte + Peinado
(16, 1,  'Corte de Cabello Dama',   'SRV-001', true,  1, 280.00, 280.00),
(16,10,  'Peinado de Fiesta',       'SRV-010', true,  1, 220.00, 220.00),   -- subtotal 500 aprox
-- Venta 17: Mechas + aceite argán
(17, 4,  'Mechas y Highlights',     'SRV-004', true,  1, 950.00, 950.00),
(17,14,  'Aceite de Argán',         'PRD-104', false,  1, 220.00, 220.00),  -- 1170 aprox ajustado a 980
-- Venta 18: Tinte
(18, 3,  'Tinte Completo',          'SRV-003', true,  1, 650.00, 650.00),
-- Venta 19: Extensiones
(19, 9,  'Extensiones de Cabello',  'SRV-009', true,  1,2500.00,2500.00),
-- Venta 20: Pedicure + Manicure
(20, 7,  'Pedicure Spa',            'SRV-007', true,  1, 250.00, 250.00),
(20, 6,  'Manicure Clásico',        'SRV-006', true,  1, 180.00, 180.00),
-- Venta 21: Keratina
(21, 5,  'Keratina Brasileña',      'SRV-005', true,  1,1200.00,1200.00),
-- Venta 22: Corte dama
(22, 1,  'Corte de Cabello Dama',   'SRV-001', true,  1, 280.00, 280.00),
-- Venta 23: Mechas + cepillo retail
(23, 4,  'Mechas y Highlights',     'SRV-004', true,  1, 650.00, 650.00),
(23,17,  'Cepillo Desenredante',    'PRD-301', false,  1, 150.00, 150.00),
-- Venta 24: Manicure + esmalte
(24, 6,  'Manicure Clásico',        'SRV-006', true,  1, 180.00, 180.00),
(24,15,  'Esmalte OPI',             'PRD-201', false,  1, 150.00, 150.00),
-- Venta 25: Mechas
(25, 4,  'Mechas y Highlights',     'SRV-004', true,  1, 950.00, 950.00);

-- ─────────────────────────────────────────────────────────────
-- 16. EVENTOS DE PERSONAL
-- ─────────────────────────────────────────────────────────────
INSERT INTO public.eventos_personal
  (empleado_id, tipo, fecha_inicio, fecha_fin, hora_inicio, hora_fin,
   horas_totales, dias_totales, subtipo, estado, justificada,
   con_goce_sueldo, motivo, registrado_por)
VALUES
(4, 'vacaciones', '2026-03-10', '2026-03-14', NULL, NULL, NULL, 5, NULL,
    'aprobado', true, true, 'Vacaciones anuales 2026', 1),
(6, 'falta',      '2026-02-20', '2026-02-22', NULL, NULL, NULL, 3, NULL,
    'aprobado', true, true, 'Incapacidad médica por gripe', 1),
(7, 'permiso',    '2026-03-28', '2026-03-28', '09:00', '14:00', 5, 1, 'personal',
    'aprobado', true, true, 'Cita médica personal', 1),
(8, 'vacaciones', '2026-04-07', '2026-04-11', NULL, NULL, NULL, 5, NULL,
    'pendiente', true, true, 'Solicitud vacaciones Semana Santa', 1),
(9, 'permiso',    '2026-04-18', '2026-04-18', '09:00', '13:00', 4, 1, 'personal',
    'aprobado', true, false, 'Trámites bancarios', 1);

-- ─────────────────────────────────────────────────────────────
-- 17. RESETEAR SECUENCIAS
-- ─────────────────────────────────────────────────────────────
SELECT setval('public.sucursales_id_seq',              3);
SELECT setval('public.puestos_id_seq',                 8);
SELECT setval('public.cat_tipos_equipo_id_seq',        8);
SELECT setval('public.cat_marcas_equipo_id_seq',      12);
SELECT setval('public.clientes_id_seq',               20);
SELECT setval('public.empleados_id_seq',              11);
SELECT setval('public.usuarios_id_seq',                7);
SELECT setval('public.empleados_modulos_id_seq',      (SELECT COUNT(*) FROM public.empleados_modulos));
SELECT setval('public.proveedores_id_seq',             8);
SELECT setval('public.inv_departamentos_id_seq',       7);
SELECT setval('public.inventarios_id_seq',            25);
SELECT setval('public.inventarios_movimientos_id_seq',(SELECT COUNT(*) FROM public.inventarios_movimientos));
SELECT setval('public.equipos_id_seq',                11);
SELECT setval('public.equipos_caracteristicas_id_seq',(SELECT COUNT(*) FROM public.equipos_caracteristicas));
SELECT setval('public.pos_ventas_id_seq',             25);
SELECT setval('public.pos_ventas_detalle_id_seq',     (SELECT COUNT(*) FROM public.pos_ventas_detalle));
SELECT setval('public.eventos_personal_id_seq',        5);

COMMIT;
