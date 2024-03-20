-- Group by/Having
-- Contagem de quantas hoteis tem mais de 5 flats
SELECT F.COD_HOTEL, COUNT(F.NUM_FLAT) AS TOTAL_FLATS
FROM FLAT F
GROUP BY F.COD_HOTEL
HAVING COUNT(F.NUM_FLAT) > 5

-- Contagem de telefones por hospede que possui mais de 1 telefone
SELECT TH.CPF_HOSPEDE, COUNT(TH.NUM_TELEFONE_HOSPEDE) AS QTD_TELEFONES
FROM TELEFONE_HOSPEDES TH
GROUP BY TH.CPF_HOSPEDE
HAVING COUNT(TH.NUM_TELEFONE_HOSPEDE) > 1


-- Junção Interna
-- Exibir o nome do reponsável e a conta do responsável
SELECT R.CPF_HOSPEDE, H.NOME_HOSPEDE, R.CONTA_RESPONSAVEL
FROM RESPONSAVEL R JOIN HOSPEDE H ON R.CPF_HOSPEDE = H.CPF_HOSPEDE

-- Exibir funcionários que tem crachá e seu respectivo crachá
SELECT C.MAT_CRACHA, F.NOME_FUNCIONARIO 
FROM FUNCIONARIO F JOIN CRACHA C ON C.CPF_FUNCIONARIO = F.CPF_FUNCIONARIO


-- Junção Externa
-- Exibir todos os funcionários, indicando os que possuem crachá e os que não possuem
SELECT C.MAT_CRACHA, F.NOME_FUNCIONARIO
FROM CRACHA C RIGHT JOIN FUNCIONARIO F ON C.CPF_FUNCIONARIO = F.CPF_FUNCIONARIO

-- Exibir todos os hoteis e informações de funcionários que trabalham nele
SELECT H.COD_HOTEL, F.CPF_FUNCIONARIO, F.NOME_FUNCIONARIO, F.CARGO_FUNCIONARIO
FROM FUNCIONARIO F
RIGHT JOIN HOTEL H ON F.COD_HOTEL = H.COD_HOTEL


-- Semi Junção
-- Hospedes que tem telefone cadastrado
SELECT DISTINCT H.CPF_HOSPEDE, H.NOME_HOSPEDE
FROM HOSPEDE H
WHERE EXISTS (
    SELECT 1
    FROM TELEFONE_HOSPEDES TH
    WHERE H.CPF_HOSPEDE = TH.CPF_HOSPEDE
)

-- Selecionar hoteis que tem funcionários cadastrados
SELECT H.COD_HOTEL, H.NUM_HOTEL
FROM HOTEL H
WHERE EXISTS (
    SELECT 1
    FROM FUNCIONARIO F
    WHERE H.COD_HOTEL = F.COD_HOTEL
)


-- Anti-Junção
-- Hospedes que não tem telefone
SELECT H.CPF_HOSPEDE, H.NOME_HOSPEDE
FROM HOSPEDE H
WHERE NOT EXISTS (
    SELECT 1
    FROM TELEFONE_HOSPEDES TH
    WHERE H.CPF_HOSPEDE = TH.CPF_HOSPEDE
)

-- Selecionar hoteis que não tem funcionários cadastrados
SELECT H.COD_HOTEL, H.NUM_HOTEL
FROM HOTEL H
WHERE NOT EXISTS (
    SELECT 1
    FROM FUNCIONARIO F
    WHERE H.COD_HOTEL = F.COD_HOTEL
)


-- Subconsulta do tipo escalar
-- Quantidade de funcionários por hotel
SELECT H.COD_HOTEL, H.NUM_HOTEL,
    (SELECT COUNT(*) FROM FUNCIONARIO F WHERE F.COD_HOTEL = H.COD_HOTEL) AS QTD_FUNCIONARIOS
FROM HOTEL H

-- Exibir hospede com maior quantidade de telefones cadastrados
SELECT H.CPF_HOSPEDE, COUNT(*) AS QTD
FROM HOSPEDE H
GROUP BY H.CPF_HOSPEDE
HAVING COUNT(*) = (
    SELECT MAX(QTD_COUNT)
    FROM (
        SELECT COUNT(*) AS QTD_COUNT
        FROM TELEFONE_HOSPEDES TH 
        GROUP BY TH.CPF_HOSPEDE
    )
)


-- Subconsulta do tipo linha
-- Exibir nome do gerente do hotel localizado no CEP 12345678 e número 111
SELECT NOME_FUNCIONARIO
FROM FUNCIONARIO
WHERE (COD_HOTEL, CARGO_FUNCIONARIO) = (
    SELECT COD_HOTEL, 'Gerente'
    FROM HOTEL
    WHERE NUM_HOTEL = 111 AND CEP_HOTEL = '12345678'
)

-- Exibir os CPFs dos responsáveis que tiveram desconto de R$100 cada e ficaram hospedados do dia 30/12/2023 até 02/01/2024 no hotel do CEP 12345678 ,NUM 111 e no flat 3
SELECT CPF_HOSPEDE FROM RESPONSAVEL_PAGA_HOSPEDAGEM RPH
WHERE (RPH.COD_HOSPEDAGENS, RPH.COD_PROMOCAO) = (
    SELECT H.COD_HOSPEDAGENS , P.COD_PROMOCAO
    FROM HOSPEDAGENS H, PROMOCAO P
    WHERE P.DESCONTO = '100.00' 
    AND H.NUM_FLAT = 3 
    AND H.DT_INIC = TO_DATE('2023-12-30 12:00:00') 
    AND H.DT_FIM = TO_DATE('2024-01-02 12:00:00') 
    AND H.COD_HOTEL = (
        SELECT COD_HOTEL FROM HOTEL
        WHERE NUM_HOTEL = 111 AND CEP_HOTEL = '12345678'
    )
)
    

-- Subconsulta do tipo tabela
-- Exibir nome dos hospedes que tem mais de 1 telefone cadastrado
SELECT H.NOME_HOSPEDE
FROM HOSPEDE H
WHERE H.CPF_HOSPEDE IN (
    SELECT TH.CPF_HOSPEDE
    FROM TELEFONE_HOSPEDES TH
    GROUP BY TH.CPF_HOSPEDE
    HAVING COUNT(*) > 1
)


--Operaçãoes de conjunto
-- Exibir todos os funcionários e seu respectivo crachá
SELECT CPF_FUNCIONARIO, NOME_FUNCIONARIO, CARGO_FUNCIONARIO, NULL AS MAT_CRACHA
FROM FUNCIONARIO
UNION
SELECT CPF_FUNCIONARIO, NULL AS NOME_FUNCIONARIO, NULL AS CARGO_FUNCIONARIO, MAT_CRACHA
FROM CRACHA

--Exibir CPF de funcionários que já foram hospedes e vice-versa
SELECT CPF_HOSPEDE
FROM HOSPEDE
INTERSECT
SELECT CPF_FUNCIONARIO
FROM FUNCIONARIO
