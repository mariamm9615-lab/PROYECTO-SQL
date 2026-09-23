-- =============================================================================
-- DataProject: Lógica de Consultas SQL — Base de datos Shakila (Pagila/Sakila)
-- Motor: PostgreSQL   |   Herramienta de trabajo: DBeaver
-- Cada bloque incluye el número de ejercicio, el enunciado como comentario y
-- la consulta resuelta. Todos los identificadores de texto se comparan con
-- ILIKE para que las consultas funcionen igual sin importar mayúsculas/
-- minúsculas (los datos de esta BBDD están almacenados en MAYÚSCULAS).
-- =============================================================================


-- =============================================================================
-- 1. Crea el esquema de la BBDD.
-- El esquema (15 tablas: actor, address, category, city, country, customer,
-- film, film_actor, film_category, inventory, language, payment, rental,
-- staff, store) se crea ejecutando en DBeaver, contra una base de datos
-- PostgreSQL vacía, el script proporcionado por el bootcamp:
--   BBDD_Proyecto_shakila_sinuser.sql
-- Un diagrama entidad-relación del resultado se incluye en el repositorio
-- en /esquema/diagrama_ER.png (generado con DBeaver: botón derecho sobre la
-- base de datos > "View Diagram").
-- =============================================================================


-- =============================================================================
-- 2. Muestra los nombres de todas las películas con una clasificación por
--    edades de 'R'.
-- =============================================================================
SELECT title
FROM film
WHERE rating = 'R'
ORDER BY title;


-- =============================================================================
-- 3. Encuentra los nombres de los actores que tengan un "actor_id" entre 30
--    y 40.
-- =============================================================================
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id BETWEEN 30 AND 40
ORDER BY actor_id;


-- =============================================================================
-- 4. Obtén las películas cuyo idioma coincide con el idioma original.
-- En esta BBDD, "original_language_id" está vacío (NULL) en todas las
-- películas: no se registró un idioma original distinto del idioma actual,
-- lo que equivale a decir que coinciden. Por eso se contempla el caso NULL.
-- =============================================================================
SELECT title, language_id, original_language_id
FROM film
WHERE original_language_id IS NULL
   OR original_language_id = language_id;


-- =============================================================================
-- 5. Ordena las películas por duración de forma ascendente.
-- =============================================================================
SELECT title, length
FROM film
ORDER BY length ASC;


-- =============================================================================
-- 6. Encuentra el nombre y apellido de los actores que tengan 'Allen' en su
--    apellido.
-- =============================================================================
SELECT first_name, last_name
FROM actor
WHERE last_name ILIKE '%Allen%';


-- =============================================================================
-- 7. Encuentra la cantidad total de películas en cada clasificación de la
--    tabla "film" y muestra la clasificación junto con el recuento.
-- =============================================================================
SELECT rating, COUNT(*) AS num_peliculas
FROM film
GROUP BY rating
ORDER BY num_peliculas DESC;


-- =============================================================================
-- 8. Encuentra el título de todas las películas que son 'PG-13' o tienen una
--    duración mayor a 3 horas en la tabla film.
-- =============================================================================
SELECT title, rating, length
FROM film
WHERE rating = 'PG-13'
   OR length > 180;  -- 3 horas = 180 minutos


-- =============================================================================
-- 9. Encuentra la variabilidad de lo que costaría reemplazar las películas.
-- La "variabilidad" se mide con la varianza y, de forma complementaria, la
-- desviación estándar (su raíz cuadrada, en las mismas unidades que el coste).
-- =============================================================================
SELECT
    VARIANCE(replacement_cost) AS varianza_coste_reemplazo,
    STDDEV(replacement_cost)   AS desviacion_estandar_coste_reemplazo
FROM film;


-- =============================================================================
-- 10. Encuentra la mayor y menor duración de una película de nuestra BBDD.
-- =============================================================================
SELECT
    MAX(length) AS duracion_maxima,
    MIN(length) AS duracion_minima
FROM film;


-- =============================================================================
-- 11. Encuentra lo que costó el antepenúltimo alquiler ordenado por día.
-- "Antepenúltimo" = el tercero empezando a contar desde el final. Se ordena
-- por fecha descendente y se salta (OFFSET) los dos últimos para quedarnos
-- con el tercero. Un mismo alquiler puede tener más de un pago asociado
-- (p. ej. alquiler + recargo), por eso se suman con SUM().
-- IMPORTANTE: 182 alquileres comparten exactamente la misma fecha máxima
-- (2006-02-14 15:16:03), un artefacto real de este dataset. Ordenar solo por
-- "rental_date" dejaría el resultado indeterminado entre esas 182 filas, así
-- que se añade "rental_id" como criterio de desempate para que la consulta
-- sea determinista y reproducible.
-- =============================================================================
WITH antepenultimo_alquiler AS (
    SELECT rental_id, rental_date
    FROM rental
    ORDER BY rental_date DESC, rental_id DESC
    OFFSET 2 LIMIT 1
)
SELECT apa.rental_id, apa.rental_date, SUM(p.amount) AS importe_total
FROM antepenultimo_alquiler apa
JOIN payment p ON p.rental_id = apa.rental_id
GROUP BY apa.rental_id, apa.rental_date;


-- =============================================================================
-- 12. Encuentra el título de las películas en la tabla "film" que no sean ni
--     'NC-17' ni 'G' en cuanto a su clasificación.
-- =============================================================================
SELECT title, rating
FROM film
WHERE rating NOT IN ('NC-17', 'G');


-- =============================================================================
-- 13. Encuentra el promedio de duración de las películas para cada
--     clasificación de la tabla film y muestra la clasificación junto con el
--     promedio de duración.
-- =============================================================================
SELECT rating, ROUND(AVG(length), 2) AS duracion_media
FROM film
GROUP BY rating
ORDER BY duracion_media DESC;


-- =============================================================================
-- 14. Encuentra el título de todas las películas que tengan una duración
--     mayor a 180 minutos.
-- =============================================================================
SELECT title, length
FROM film
WHERE length > 180
ORDER BY length DESC;


-- =============================================================================
-- 15. ¿Cuánto dinero ha generado en total la empresa?
-- =============================================================================
SELECT SUM(amount) AS ingresos_totales
FROM payment;


-- =============================================================================
-- 16. Muestra los 10 clientes con mayor valor de id.
-- =============================================================================
SELECT customer_id, first_name, last_name
FROM customer
ORDER BY customer_id DESC
LIMIT 10;


-- =============================================================================
-- 17. Encuentra el nombre y apellido de los actores que aparecen en la
--     película con título 'Egg Igby'.
-- =============================================================================
SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
JOIN film f ON f.film_id = fa.film_id
WHERE f.title ILIKE 'Egg Igby';


-- =============================================================================
-- 18. Selecciona todos los nombres de las películas únicos.
-- =============================================================================
SELECT DISTINCT title
FROM film
ORDER BY title;


-- =============================================================================
-- 19. Encuentra el título de las películas que son comedias y tienen una
--     duración mayor a 180 minutos en la tabla "film".
-- =============================================================================
SELECT f.title, f.length
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
WHERE c.name ILIKE 'Comedy'
  AND f.length > 180;


-- =============================================================================
-- 20. Encuentra las categorías de películas que tienen un promedio de
--     duración superior a 110 minutos y muestra el nombre de la categoría
--     junto con el promedio de duración.
-- =============================================================================
SELECT c.name AS categoria, ROUND(AVG(f.length), 2) AS duracion_media
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
GROUP BY c.name
HAVING AVG(f.length) > 110
ORDER BY duracion_media DESC;


-- =============================================================================
-- 21. ¿Cuál es la media de duración del alquiler de las películas?
-- Se refiere a la duración REAL de cada alquiler (fecha de devolución menos
-- fecha de alquiler), no al campo "rental_duration" de la tabla film (que es
-- solo el nº de días permitidos). Se excluyen los alquileres aún no
-- devueltos (return_date NULL).
-- =============================================================================
SELECT AVG(return_date - rental_date) AS duracion_media_alquiler
FROM rental
WHERE return_date IS NOT NULL;


-- =============================================================================
-- 22. Crea una columna con el nombre y apellidos de todos los actores y
--     actrices.
-- =============================================================================
SELECT first_name || ' ' || last_name AS nombre_completo
FROM actor
ORDER BY nombre_completo;


-- =============================================================================
-- 23. Números de alquiler por día, ordenados por cantidad de alquiler de
--     forma descendente.
-- =============================================================================
SELECT DATE(rental_date) AS dia, COUNT(*) AS num_alquileres
FROM rental
GROUP BY DATE(rental_date)
ORDER BY num_alquileres DESC;


-- =============================================================================
-- 24. Encuentra las películas con una duración superior al promedio.
-- =============================================================================
SELECT title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length DESC;


-- =============================================================================
-- 25. Averigua el número de alquileres registrados por mes.
-- =============================================================================
SELECT DATE_TRUNC('month', rental_date)::date AS mes, COUNT(*) AS num_alquileres
FROM rental
GROUP BY mes
ORDER BY mes;


-- =============================================================================
-- 26. Encuentra el promedio, la desviación estándar y varianza del total
--     pagado.
-- =============================================================================
SELECT
    AVG(amount)      AS promedio_pagado,
    STDDEV(amount)   AS desviacion_estandar,
    VARIANCE(amount) AS varianza
FROM payment;


-- =============================================================================
-- 27. ¿Qué películas se alquilan por encima del precio medio?
-- Se interpreta "precio" como la tarifa de alquiler de la película
-- (film.rental_rate).
-- =============================================================================
SELECT title, rental_rate
FROM film
WHERE rental_rate > (SELECT AVG(rental_rate) FROM film)
ORDER BY rental_rate DESC;


-- =============================================================================
-- 28. Muestra el id de los actores que hayan participado en más de 40
--     películas.
-- =============================================================================
SELECT actor_id, COUNT(*) AS num_peliculas
FROM film_actor
GROUP BY actor_id
HAVING COUNT(*) > 40
ORDER BY num_peliculas DESC;


-- =============================================================================
-- 29. Obtener todas las películas y, si están disponibles en el inventario,
--     mostrar la cantidad disponible.
-- Una copia está "disponible" si no tiene ningún alquiler abierto (sin
-- devolver, return_date IS NULL) en este momento.
-- =============================================================================
SELECT
    f.film_id,
    f.title,
    COUNT(i.inventory_id) FILTER (
        WHERE NOT EXISTS (
            SELECT 1 FROM rental r
            WHERE r.inventory_id = i.inventory_id
              AND r.return_date IS NULL
        )
    ) AS copias_disponibles
FROM film f
LEFT JOIN inventory i ON i.film_id = f.film_id
GROUP BY f.film_id, f.title
ORDER BY f.title;


-- =============================================================================
-- 30. Obtener los actores y el número de películas en las que ha actuado.
-- =============================================================================
SELECT a.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS num_peliculas
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY num_peliculas DESC;


-- =============================================================================
-- 31. Obtener todas las películas y mostrar los actores que han actuado en
--     ellas, incluso si algunas películas no tienen actores asociados.
-- =============================================================================
SELECT f.title, a.first_name, a.last_name
FROM film f
LEFT JOIN film_actor fa ON fa.film_id = f.film_id
LEFT JOIN actor a ON a.actor_id = fa.actor_id
ORDER BY f.title;


-- =============================================================================
-- 32. Obtener todos los actores y mostrar las películas en las que han
--     actuado, incluso si algunos actores no han actuado en ninguna
--     película.
-- =============================================================================
SELECT a.first_name, a.last_name, f.title
FROM actor a
LEFT JOIN film_actor fa ON fa.actor_id = a.actor_id
LEFT JOIN film f ON f.film_id = fa.film_id
ORDER BY a.last_name, a.first_name;


-- =============================================================================
-- 33. Obtener todas las películas que tenemos y todos los registros de
--     alquiler.
-- FULL OUTER JOIN encadenado a través de inventory (rental no referencia a
-- film directamente): así aparecen tanto películas sin alquileres como
-- (si los hubiera) alquileres sin película asociada.
-- =============================================================================
SELECT f.film_id, f.title, r.rental_id, r.rental_date
FROM film f
FULL OUTER JOIN inventory i ON i.film_id = f.film_id
FULL OUTER JOIN rental r ON r.inventory_id = i.inventory_id
ORDER BY f.title;


-- =============================================================================
-- 34. Encuentra los 5 clientes que más dinero se hayan gastado con
--     nosotros.
-- =============================================================================
SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_gastado
FROM customer c
JOIN payment p ON p.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_gastado DESC
LIMIT 5;


-- =============================================================================
-- 35. Selecciona todos los actores cuyo primer nombre es 'Johnny'.
-- =============================================================================
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name ILIKE 'Johnny';


-- =============================================================================
-- 36. Renombra la columna "first_name" como Nombre y "last_name" como
--     Apellido.
-- =============================================================================
SELECT first_name AS "Nombre", last_name AS "Apellido"
FROM actor;


-- =============================================================================
-- 37. Encuentra el ID del actor más bajo y más alto en la tabla actor.
-- =============================================================================
SELECT MIN(actor_id) AS id_minimo, MAX(actor_id) AS id_maximo
FROM actor;


-- =============================================================================
-- 38. Cuenta cuántos actores hay en la tabla "actor".
-- =============================================================================
SELECT COUNT(*) AS total_actores
FROM actor;


-- =============================================================================
-- 39. Selecciona todos los actores y ordénalos por apellido en orden
--     ascendente.
-- =============================================================================
SELECT actor_id, first_name, last_name
FROM actor
ORDER BY last_name ASC;


-- =============================================================================
-- 40. Selecciona las primeras 5 películas de la tabla "film".
-- Se ordena explícitamente por film_id: sin un ORDER BY, "las primeras 5"
-- de una tabla no está garantizado en SQL (el orden físico no es fiable).
-- =============================================================================
SELECT film_id, title
FROM film
ORDER BY film_id
LIMIT 5;


-- =============================================================================
-- 41. Agrupa los actores por su nombre y cuenta cuántos actores tienen el
--     mismo nombre. ¿Cuál es el nombre más repetido?
-- Resultado en esta BBDD: hay un triple empate en primer lugar entre JULIA,
-- KENNETH y PENELOPE, con 4 actores cada uno.
-- =============================================================================
SELECT first_name, COUNT(*) AS num_actores
FROM actor
GROUP BY first_name
ORDER BY num_actores DESC;


-- =============================================================================
-- 42. Encuentra todos los alquileres y los nombres de los clientes que los
--     realizaron.
-- =============================================================================
SELECT r.rental_id, r.rental_date, c.first_name, c.last_name
FROM rental r
JOIN customer c ON c.customer_id = r.customer_id
ORDER BY r.rental_date;


-- =============================================================================
-- 43. Muestra todos los clientes y sus alquileres si existen, incluyendo
--     aquellos que no tienen alquileres.
-- =============================================================================
SELECT c.customer_id, c.first_name, c.last_name, r.rental_id, r.rental_date
FROM customer c
LEFT JOIN rental r ON r.customer_id = c.customer_id
ORDER BY c.customer_id;


-- =============================================================================
-- 44. Realiza un CROSS JOIN entre las tablas film y category. ¿Aporta valor
--     esta consulta? ¿Por qué? Deja después de la consulta la contestación.
-- =============================================================================
SELECT f.title, c.name AS categoria
FROM film f
CROSS JOIN category c;

-- Respuesta: No, este CROSS JOIN no aporta valor analítico. Combina cada una
-- de las 1.000 películas con cada una de las 16 categorías (16.000 filas en
-- total), generando combinaciones ficticias que no reflejan la categoría
-- real de cada película (esa relación real ya existe en la tabla puente
-- film_category). Un CROSS JOIN solo tiene sentido cuando realmente
-- queremos "todas las combinaciones posibles" entre dos conjuntos sin
-- relación (como en el ejercicio 63, trabajadores x tiendas); aquí, como sí
-- existe una relación real entre film y category, lo correcto es un INNER
-- JOIN a través de film_category.


-- =============================================================================
-- 45. Encuentra los actores que han participado en películas de la
--     categoría 'Action'.
-- =============================================================================
SELECT DISTINCT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
JOIN film_category fc ON fc.film_id = fa.film_id
JOIN category c ON c.category_id = fc.category_id
WHERE c.name ILIKE 'Action'
ORDER BY a.last_name;


-- =============================================================================
-- 46. Encuentra todos los actores que no han participado en películas.
-- Resultado en esta BBDD: 0 filas. Los 200 actores de la tabla "actor"
-- tienen, todos, al menos una película asociada en "film_actor".
-- =============================================================================
SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
WHERE NOT EXISTS (
    SELECT 1 FROM film_actor fa WHERE fa.actor_id = a.actor_id
);


-- =============================================================================
-- 47. Selecciona el nombre de los actores y la cantidad de películas en las
--     que han participado.
-- A diferencia del ejercicio 30 (INNER JOIN), aquí se usa LEFT JOIN para
-- que también aparezcan, con un 0, actores sin ninguna película (aunque en
-- esta BBDD concreta no existe ninguno, ver ejercicio 46).
-- =============================================================================
SELECT a.first_name, a.last_name, COUNT(fa.film_id) AS num_peliculas
FROM actor a
LEFT JOIN film_actor fa ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY num_peliculas DESC;


-- =============================================================================
-- 48. Crea una vista llamada "actor_num_peliculas" que muestre los nombres
--     de los actores y el número de películas en las que han participado.
-- =============================================================================
DROP VIEW IF EXISTS actor_num_peliculas;

CREATE VIEW actor_num_peliculas AS
SELECT a.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS num_peliculas
FROM actor a
LEFT JOIN film_actor fa ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name;

-- Consulta de prueba de la vista:
SELECT * FROM actor_num_peliculas ORDER BY num_peliculas DESC LIMIT 10;


-- =============================================================================
-- 49. Calcula el número total de alquileres realizados por cada cliente.
-- =============================================================================
SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS total_alquileres
FROM customer c
LEFT JOIN rental r ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_alquileres DESC;


-- =============================================================================
-- 50. Calcula la duración total de las películas en la categoría 'Action'.
-- =============================================================================
SELECT SUM(f.length) AS duracion_total_minutos
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
WHERE c.name ILIKE 'Action';


-- =============================================================================
-- 51. Crea una tabla temporal llamada "cliente_rentas_temporal" para
--     almacenar el total de alquileres por cliente.
-- =============================================================================
DROP TABLE IF EXISTS cliente_rentas_temporal;

CREATE TEMPORARY TABLE cliente_rentas_temporal AS
SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS total_alquileres
FROM customer c
LEFT JOIN rental r ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- Consulta de prueba de la tabla temporal:
SELECT * FROM cliente_rentas_temporal ORDER BY total_alquileres DESC LIMIT 10;


-- =============================================================================
-- 52. Crea una tabla temporal llamada "peliculas_alquiladas" que almacene
--     las películas que han sido alquiladas al menos 10 veces.
-- =============================================================================
DROP TABLE IF EXISTS peliculas_alquiladas;

CREATE TEMPORARY TABLE peliculas_alquiladas AS
SELECT f.film_id, f.title, COUNT(r.rental_id) AS veces_alquilada
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY f.film_id, f.title
HAVING COUNT(r.rental_id) >= 10;

-- Consulta de prueba de la tabla temporal:
SELECT * FROM peliculas_alquiladas ORDER BY veces_alquilada DESC LIMIT 10;


-- =============================================================================
-- 53. Encuentra el título de las películas que han sido alquiladas por el
--     cliente con el nombre 'Tammy Sanders' y que aún no se han devuelto.
--     Ordena los resultados alfabéticamente por título de película.
-- =============================================================================
SELECT f.title
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN customer c ON c.customer_id = r.customer_id
WHERE c.first_name ILIKE 'Tammy'
  AND c.last_name ILIKE 'Sanders'
  AND r.return_date IS NULL
ORDER BY f.title;


-- =============================================================================
-- 54. Encuentra los nombres de los actores que han actuado en al menos una
--     película que pertenece a la categoría 'Sci-Fi'. Ordena los resultados
--     alfabéticamente por apellido.
-- =============================================================================
SELECT DISTINCT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
JOIN film_category fc ON fc.film_id = fa.film_id
JOIN category c ON c.category_id = fc.category_id
WHERE c.name ILIKE 'Sci-Fi'
ORDER BY a.last_name;


-- =============================================================================
-- 55. Encuentra el nombre y apellido de los actores que han actuado en
--     películas que se alquilaron después de que la película 'Spartacus
--     Cheaper' se alquilara por primera vez. Ordena los resultados
--     alfabéticamente por apellido.
-- =============================================================================
WITH primer_alquiler_spartacus AS (
    SELECT MIN(r.rental_date) AS fecha
    FROM rental r
    JOIN inventory i ON i.inventory_id = r.inventory_id
    JOIN film f ON f.film_id = i.film_id
    WHERE f.title ILIKE 'Spartacus Cheaper'
)
SELECT DISTINCT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
JOIN film f ON f.film_id = fa.film_id
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
WHERE r.rental_date > (SELECT fecha FROM primer_alquiler_spartacus)
ORDER BY a.last_name;


-- =============================================================================
-- 56. Encuentra el nombre y apellido de los actores que no han actuado en
--     ninguna película de la categoría 'Music'.
-- =============================================================================
SELECT a.first_name, a.last_name
FROM actor a
WHERE a.actor_id NOT IN (
    SELECT fa.actor_id
    FROM film_actor fa
    JOIN film_category fc ON fc.film_id = fa.film_id
    JOIN category c ON c.category_id = fc.category_id
    WHERE c.name ILIKE 'Music'
)
ORDER BY a.last_name;


-- =============================================================================
-- 57. Encuentra el título de todas las películas que fueron alquiladas por
--     más de 8 días.
-- Se calcula la duración real de cada alquiler ya devuelto
-- (return_date - rental_date) y se filtran los que superan los 8 días.
-- =============================================================================
SELECT DISTINCT f.title
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
WHERE r.return_date IS NOT NULL
  AND (r.return_date - r.rental_date) > INTERVAL '8 days'
ORDER BY f.title;


-- =============================================================================
-- 58. Encuentra el título de todas las películas que son de la misma
--     categoría que 'Animation'.
-- =============================================================================
SELECT f.title
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
WHERE c.name ILIKE 'Animation'
ORDER BY f.title;


-- =============================================================================
-- 59. Encuentra los nombres de las películas que tienen la misma duración
--     que la película con el título 'Dancing Fever'. Ordena los resultados
--     alfabéticamente por título de película.
-- =============================================================================
SELECT title, length
FROM film
WHERE length = (SELECT length FROM film WHERE title ILIKE 'Dancing Fever')
  AND title NOT ILIKE 'Dancing Fever'
ORDER BY title;


-- =============================================================================
-- 60. Encuentra los nombres de los clientes que han alquilado al menos 7
--     películas distintas. Ordena los resultados alfabéticamente por
--     apellido.
-- Resultado en esta BBDD: los 599 clientes cumplen la condición (es el total
-- de clientes existentes). Tiene sentido: con 16.044 alquileres repartidos
-- entre 599 clientes, la media es de ~27 alquileres por cliente, muy por
-- encima del umbral de 7 películas distintas.
-- =============================================================================
SELECT c.customer_id, c.first_name, c.last_name, COUNT(DISTINCT i.film_id) AS peliculas_distintas
FROM customer c
JOIN rental r ON r.customer_id = c.customer_id
JOIN inventory i ON i.inventory_id = r.inventory_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT i.film_id) >= 7
ORDER BY c.last_name;


-- =============================================================================
-- 61. Encuentra la cantidad total de películas alquiladas por categoría y
--     muestra el nombre de la categoría junto con el recuento de
--     alquileres.
-- =============================================================================
SELECT c.name AS categoria, COUNT(r.rental_id) AS total_alquileres
FROM category c
JOIN film_category fc ON fc.category_id = c.category_id
JOIN inventory i ON i.film_id = fc.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY c.name
ORDER BY total_alquileres DESC;


-- =============================================================================
-- 62. Encuentra el número de películas por categoría estrenadas en 2006.
-- =============================================================================
SELECT c.name AS categoria, COUNT(*) AS num_peliculas
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
WHERE f.release_year = 2006
GROUP BY c.name
ORDER BY num_peliculas DESC;


-- =============================================================================
-- 63. Obtén todas las combinaciones posibles de trabajadores con las
--     tiendas que tenemos.
-- Aquí sí tiene sentido un CROSS JOIN: no existe relación real entre cada
-- empleado y cada tienda salvo la que ya tiene asignada, y el ejercicio pide
-- explícitamente "todas las combinaciones posibles".
-- =============================================================================
SELECT s.first_name, s.last_name, st.store_id
FROM staff s
CROSS JOIN store st
ORDER BY s.last_name, st.store_id;


-- =============================================================================
-- 64. Encuentra la cantidad total de películas alquiladas por cada cliente
--     y muestra el ID del cliente, su nombre y apellido junto con la
--     cantidad de películas alquiladas.
-- =============================================================================
SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS peliculas_alquiladas
FROM customer c
JOIN rental r ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY peliculas_alquiladas DESC;
