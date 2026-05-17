USE master;
DROP DATABASE IF EXISTS FoodChainGraphDB;
CREATE DATABASE FoodChainGraphDB;
USE FoodChainGraphDB;


-- ==========================================
-- 1. СОЗДАНИЕ ТАБЛИЦ УЗЛОВ
-- ==========================================

-- Узел 1: Хищники
CREATE TABLE Predator (
    ID INT NOT NULL IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    AnimalClass NVARCHAR(50) NOT NULL
) AS NODE;

-- Узел 2: Добыча
CREATE TABLE Prey (
    ID INT NOT NULL IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    DietType NVARCHAR(50) NOT NULL
) AS NODE;

-- Узел 3: Среда
CREATE TABLE Environment (
    ID INT NOT NULL IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Climate NVARCHAR(50) NOT NULL
) AS NODE;


-- ==========================================
-- 2. СОЗДАНИЕ ТАБЛИЦ РЁБЕР (EDGES)
-- ==========================================

-- Ребро 1: Охотится на / Ест
CREATE TABLE Eats (
    DietPercentage INT CHECK (DietPercentage BETWEEN 0 AND 100),
    CONSTRAINT EC_Eats CONNECTION (
        Predator TO Prey,
        Predator TO Predator
    )
) AS EDGE;

-- Ребро 2: Обитает в
CREATE TABLE Inhabits (
    PopulationDensity INT CHECK (PopulationDensity >= 0),
    CONSTRAINT EC_Inhabits CONNECTION (
        Predator TO Environment,
        Prey TO Environment
    )
) AS EDGE;

-- Ребро 3: Конкурирует с 
CREATE TABLE CompetesForPrey (
    Intensity INT CHECK (Intensity BETWEEN 1 AND 10),
    CONSTRAINT EC_CompetesForPrey CONNECTION (
        Predator TO Predator
    )
) AS EDGE;


-- ==========================================
-- 3. ЗАПОЛНЕНИЕ УЗЛОВ
-- ==========================================

-- Predator
INSERT INTO Predator (Name, AnimalClass) 
VALUES ('Bear', 'Mammals')
        , ('Wolf', 'Mammals')
        , ('Fox', 'Mammals')
        , ('Eagle', 'Birds')
        , ('Snake', 'Reptiles')
        , ('Owl', 'Birds')
        , ('Tiger', 'Mammals')
        , ('Lion', 'Mammals')
        , ('Crocodile', 'Reptiles')
        , ('Shark', 'Fish')
        , ('Orca', 'Mammals');

SELECT * FROM Predator;

-- Prey (Жертвы / Добыча)
INSERT INTO Prey (Name, DietType) 
VALUES ('Hare', 'Herbivore')
        , ('Mouse', 'Omnivore')
        , ('Deer', 'Herbivore')
        , ('Wild Boar', 'Omnivore')
        , ('Zebra', 'Herbivore')
        , ('Antelope', 'Herbivore')
        , ('Fish', 'Omnivore')
        , ('Frog', 'Insectivore')
        , ('Insect', 'Herbivore')
        , ('Seal', 'Carnivore');

SELECT * FROM Prey;

-- Environment (Среда)
INSERT INTO Environment (Name, Climate) 
VALUES ('Forest', 'Temperate')
        , ('Steppe', 'Temperate')
        , ('Taiga', 'Cold')
        , ('Desert', 'Hot')
        , ('Savanna', 'Hot')
        , ('Jungle', 'Tropical')
        , ('Mountains', 'Temperate')
        , ('River', 'Varied')
        , ('Ocean', 'Varied')
        , ('Swamp', 'Humid');

SELECT * FROM Environment;


-- ==========================================
-- 4. ЗАПОЛНЕНИЕ РЁБЕР
-- ==========================================

-- Eats (Охотится на / Ест)
INSERT INTO Eats ($from_id, $to_id, DietPercentage)
VALUES 
-- Хищник ест Жертву
((SELECT $node_id FROM Predator WHERE Name = 'Wolf'), (SELECT $node_id FROM Prey WHERE Name = 'Deer'), 64),
((SELECT $node_id FROM Predator WHERE Name = 'Fox'), (SELECT $node_id FROM Prey WHERE Name = 'Hare'), 52),
((SELECT $node_id FROM Predator WHERE Name = 'Eagle'), (SELECT $node_id FROM Prey WHERE Name = 'Mouse'), 45),
((SELECT $node_id FROM Predator WHERE Name = 'Tiger'), (SELECT $node_id FROM Prey WHERE Name = 'Wild Boar'), 60),
((SELECT $node_id FROM Predator WHERE Name = 'Lion'), (SELECT $node_id FROM Prey WHERE Name = 'Zebra'), 41),
((SELECT $node_id FROM Predator WHERE Name = 'Shark'), (SELECT $node_id FROM Prey WHERE Name = 'Seal'), 17),
-- Хищник ест Хищника
((SELECT $node_id FROM Predator WHERE Name = 'Bear'), (SELECT $node_id FROM Predator WHERE Name = 'Wolf'), 33),
((SELECT $node_id FROM Predator WHERE Name = 'Wolf'), (SELECT $node_id FROM Predator WHERE Name = 'Fox'), 34),
((SELECT $node_id FROM Predator WHERE Name = 'Fox'), (SELECT $node_id FROM Predator WHERE Name = 'Owl'), 24),
((SELECT $node_id FROM Predator WHERE Name = 'Orca'), (SELECT $node_id FROM Predator WHERE Name = 'Shark'), 28);
GO

SELECT * FROM Eats;

-- Inhabits (Обитает в)
INSERT INTO Inhabits ($from_id, $to_id, PopulationDensity)
VALUES
-- Хищники
((SELECT $node_id FROM Predator WHERE Name = 'Wolf'), (SELECT $node_id FROM Environment WHERE Name = 'Forest'), 15),
((SELECT $node_id FROM Predator WHERE Name = 'Lion'), (SELECT $node_id FROM Environment WHERE Name = 'Savanna'), 5),
((SELECT $node_id FROM Predator WHERE Name = 'Tiger'), (SELECT $node_id FROM Environment WHERE Name = 'Jungle'), 3),
((SELECT $node_id FROM Predator WHERE Name = 'Eagle'), (SELECT $node_id FROM Environment WHERE Name = 'Mountains'), 15),
((SELECT $node_id FROM Predator WHERE Name = 'Snake'), (SELECT $node_id FROM Environment WHERE Name = 'Desert'), 30),
((SELECT $node_id FROM Predator WHERE Name = 'Bear'), (SELECT $node_id FROM Environment WHERE Name = 'Forest'), 4),
((SELECT $node_id FROM Predator WHERE Name = 'Fox'), (SELECT $node_id FROM Environment WHERE Name = 'Forest'), 12),
((SELECT $node_id FROM Predator WHERE Name = 'Owl'), (SELECT $node_id FROM Environment WHERE Name = 'Forest'), 8),
((SELECT $node_id FROM Predator WHERE Name = 'Crocodile'), (SELECT $node_id FROM Environment WHERE Name = 'River'), 6),
((SELECT $node_id FROM Predator WHERE Name = 'Shark'), (SELECT $node_id FROM Environment WHERE Name = 'Ocean'), 2),
((SELECT $node_id FROM Predator WHERE Name = 'Orca'), (SELECT $node_id FROM Environment WHERE Name = 'Ocean'), 1),
-- Жертвы / Добыча
((SELECT $node_id FROM Prey WHERE Name = 'Deer'), (SELECT $node_id FROM Environment WHERE Name = 'Forest'), 20),
((SELECT $node_id FROM Prey WHERE Name = 'Zebra'), (SELECT $node_id FROM Environment WHERE Name = 'Savanna'), 30),
((SELECT $node_id FROM Prey WHERE Name = 'Frog'), (SELECT $node_id FROM Environment WHERE Name = 'Swamp'), 70),
((SELECT $node_id FROM Prey WHERE Name = 'Hare'), (SELECT $node_id FROM Environment WHERE Name = 'Forest'), 45),
((SELECT $node_id FROM Prey WHERE Name = 'Mouse'), (SELECT $node_id FROM Environment WHERE Name = 'Steppe'), 120),
((SELECT $node_id FROM Prey WHERE Name = 'Wild Boar'), (SELECT $node_id FROM Environment WHERE Name = 'Taiga'), 18),
((SELECT $node_id FROM Prey WHERE Name = 'Antelope'), (SELECT $node_id FROM Environment WHERE Name = 'Savanna'), 25),
((SELECT $node_id FROM Prey WHERE Name = 'Fish'), (SELECT $node_id FROM Environment WHERE Name = 'River'), 150),
((SELECT $node_id FROM Prey WHERE Name = 'Insect'), (SELECT $node_id FROM Environment WHERE Name = 'Swamp'), 500),
((SELECT $node_id FROM Prey WHERE Name = 'Seal'), (SELECT $node_id FROM Environment WHERE Name = 'Ocean'), 15);
GO

SELECT * FROM Inhabits;


-- CompetesForPrey (Конкурирует с)  
INSERT INTO CompetesForPrey ($from_id, $to_id, Intensity)
VALUES
((SELECT $node_id FROM Predator WHERE Name = 'Lion'), (SELECT $node_id FROM Predator WHERE Name = 'Crocodile'), 8),
((SELECT $node_id FROM Predator WHERE Name = 'Crocodile'), (SELECT $node_id FROM Predator WHERE Name = 'Shark'), 5),
((SELECT $node_id FROM Predator WHERE Name = 'Shark'), (SELECT $node_id FROM Predator WHERE Name = 'Orca'), 7),
((SELECT $node_id FROM Predator WHERE Name = 'Wolf'), (SELECT $node_id FROM Predator WHERE Name = 'Bear'), 5),
((SELECT $node_id FROM Predator WHERE Name = 'Wolf'), (SELECT $node_id FROM Predator WHERE Name = 'Fox'), 6),
((SELECT $node_id FROM Predator WHERE Name = 'Eagle'), (SELECT $node_id FROM Predator WHERE Name = 'Owl'), 4);
GO

SELECT * FROM CompetesForPrey;


-- ==========================================
-- 5. 5 ЗАПРОСОВ С ИСПОЛЬЗОВАНИЕМ MATCH
-- ==========================================

-- 1: Какую жертву ест Волк?
SELECT p.Name AS Predator, pr.Name AS Prey, e.DietPercentage 
FROM Predator AS p
    , Eats AS e
    , Prey AS pr 
WHERE MATCH(p-(e)->pr) AND p.Name = 'Wolf';

-- 2:  каких средах обитают хищники?
SELECT p.Name AS Predator, env.Name AS Environment
FROM Predator AS p
    , Inhabits AS i
    , Environment AS env
WHERE MATCH(p-(i)->env);

-- 3: Найти среды обитания, в которых живут жертвы, съедаемые Львом.
SELECT p.Name AS Predator, pr.Name AS Prey, env.Name AS Environment
FROM Predator AS p
    , Eats AS e
    , Prey AS pr
    , Inhabits AS i
    , Environment AS env
WHERE MATCH(p-(e)->pr-(i)->env) AND p.Name = 'Lion';

-- 4: Найти хищников, которые конкурируют с теми, кто живет в Реке.
SELECT p1.Name AS Competitor1, p2.Name AS Competitor2, env.Name AS Environment
FROM Predator AS p1
    , CompetesForPrey AS c
    , Predator AS p2
    , Inhabits AS i
    , Environment AS env
WHERE MATCH(p1-(c)->p2-(i)->env) AND env.Name = 'River';

-- 5:  Найти хищников и жертв, которые обитают в одной и той же среде (лес).
SELECT p.Name AS Predator, pr.Name AS Prey, env.Name AS CommonEnvironment
FROM Predator AS p
    , Inhabits AS i1
    , Environment AS env
    , Prey AS pr
    , Inhabits AS i2
WHERE MATCH(p-(i1)->env and pr-(i2)->env) AND env.Name = 'Forest';


-- ==========================================
-- 6. 2 ЗАПРОСА С ИСПОЛЬЗОВАНИЕМ SHORTEST_PATH
-- ==========================================

-- 1. Поиск всей пищевой цепи хищников, начинающейся с Медведя.
SELECT 
    p1.Name AS ApexPredator,
    STRING_AGG(p2.Name, ' -> ') WITHIN GROUP (GRAPH PATH) AS PredatorFoodChain
FROM 
    Predator p1,
    Eats FOR PATH e,
    Predator FOR PATH p2
WHERE 
    MATCH(SHORTEST_PATH(p1(-(e)->p2)+))
    AND p1.Name = 'Bear';

-- 2. Поиск цепочки конкуренции хищников, начиная со Льва.
SELECT 
    p1.Name AS StartPredator,
    STRING_AGG(p2.Name, ' <-> ') WITHIN GROUP (GRAPH PATH) AS CompetitionChain
FROM 
    Predator p1,
    CompetesForPrey FOR PATH c,
    Predator FOR PATH p2
WHERE 
    MATCH(SHORTEST_PATH(p1(-(c)->p2){1,3}))
    AND p1.Name = 'Lion';
