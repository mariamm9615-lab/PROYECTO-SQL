# 🎬 Lógica de Consultas SQL — Base de datos Shakila (Pagila/Sakila)

64 consultas de análisis sobre una base de datos de alquiler de películas, resueltas en **PostgreSQL** con **DBeaver**: una sola tabla, relaciones entre tablas, subconsultas, vistas y estructuras de datos temporales.

> Proyecto del Bootcamp de Data & Analytics — Módulo *Lógica de Consultas SQL*.

---

## 📝 Descripción del proyecto

El objetivo es demostrar el manejo de SQL sobre una base de datos relacional real, cubriendo los bloques de conocimiento exigidos por el enunciado:

- Manejo de la herramienta **DBeaver**.
- Consultas con una sola tabla.
- Relaciones entre tablas (`INNER JOIN`, `LEFT/RIGHT JOIN`, `FULL OUTER JOIN`, `CROSS JOIN`).
- Subconsultas (en `WHERE`, en cláusulas `WITH`/CTE).
- Vistas (`CREATE VIEW`).
- Estructuras de datos temporales (`CREATE TEMPORARY TABLE`).
- Buenas prácticas: consultas comentadas, alias legibles, JOIN correcto en cada caso.

**Base de datos:** Shakila, una variante en PostgreSQL de la conocida base de datos de ejemplo *Sakila* (MySQL) / *Pagila* (PostgreSQL) de una cadena de alquiler de películas: películas, actores, categorías, clientes, empleados, tiendas, alquileres y pagos. Proporcionada por el bootcamp como archivo `.sql` (`esquema/shakila_schema.sql`).

Antes de escribir una sola consulta se exploró el esquema completo (15 tablas, 22 claves foráneas) para entender las relaciones reales entre tablas — ver `esquema/esquema_bbdd.png`.

---

## 🗂️ Estructura del repositorio

```
├── README.md              <- este archivo
├── consultas.sql           <- las 64 consultas, numeradas y comentadas
└── esquema/
    ├── esquema_bbdd.png    <- diagrama entidad-relación de la BBDD
    └── shakila_schema.sql  <- script de creación de la BBDD proporcionado por el bootcamp
```

---

## ⚙️ Instalación y requisitos

1. Instalar **PostgreSQL** (≥ 13) y **DBeaver**.
2. Crear una base de datos vacía, por ejemplo `shakila`.
3. En DBeaver, conectar contra esa base de datos y ejecutar el script `esquema/shakila_schema.sql` para crear las 15 tablas y cargar los datos de partida.
4. Abrir `consultas.sql` en DBeaver (conectado a la base `shakila`) y ejecutar los bloques en orden. Cada consulta empieza con un comentario `-- N. <enunciado>`, por lo que pueden ejecutarse una a una con `Ctrl+Enter`.

> Todas las consultas se verificaron ejecutándolas de principio a fin contra la base de datos real, sin ningún error, antes de entregarlas.

---

## 📈 Metodología y hallazgos relevantes del análisis

Además de resolver cada enunciado, se ha comprobado que el resultado obtenido tiene sentido de negocio. Algunos hallazgos destacados durante ese proceso:

- **Ejercicio 4** (películas cuyo idioma coincide con el original): en esta base de datos, `original_language_id` está vacío en las 1.000 películas — no se registró nunca un idioma original distinto —, así que la consulta contempla explícitamente ese caso con `IS NULL`.
- **Ejercicio 11** (coste del antepenúltimo alquiler): se detectó que **182 alquileres comparten la misma fecha exacta** al final del dataset. Ordenar solo por fecha deja el resultado indeterminado, así que se añadió `rental_id` como criterio de desempate para que la consulta sea reproducible.
- **Ejercicio 46** (actores sin película): devuelve 0 filas — los 200 actores de la tabla tienen, todos, al menos una película asociada.
- **Ejercicio 60** (clientes con ≥ 7 películas distintas alquiladas): lo cumplen los **599 clientes**, es decir, todos — con 16.044 alquileres repartidos entre 599 clientes (~27 de media), el umbral de 7 resulta poco exigente para este dataset.
- **Ejercicio 44** (CROSS JOIN entre `film` y `category`): se responde en el propio archivo `.sql` que no aporta valor analítico, porque genera 16.000 combinaciones ficticias que no reflejan la categoría real de cada película (esa relación ya existe en la tabla puente `film_category`); un `CROSS JOIN` sí tiene sentido en el ejercicio 63, donde se piden explícitamente todas las combinaciones posibles de empleados y tiendas.

---

## 🔭 Próximos pasos

- Añadir índices sobre las columnas más consultadas (`rental.rental_date`, `payment.customer_id`) si el volumen de datos creciera.
- Convertir alguna de las subconsultas correlacionadas (ejercicios 55/56) en funciones o vistas reutilizables si se repitieran en más informes.

---

## 🤝 Contribuciones

Proyecto académico individual, no abierto a contribuciones externas.

---

## 👤 Autoría

- **Autora:** María — Bootcamp Data & Analytics.
- **Base de datos:** Shakila (variante de Sakila/Pagila), proporcionada por el bootcamp.
