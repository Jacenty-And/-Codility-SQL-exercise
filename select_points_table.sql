CREATE TEMPORARY TABLE results_table AS
SELECT host_team, guest_team,
CASE
    WHEN host_goals > guest_goals
    THEN 3
    WHEN host_goals < guest_goals
    THEN 0
    ELSE 1
END AS host_points,
CASE
    WHEN host_goals < guest_goals
    THEN 3
    WHEN host_goals > guest_goals
    THEN 0
    ELSE 1
END AS guest_points
FROM matches;

CREATE TEMPORARY TABLE host_points_table AS
SELECT host_team, SUM(host_points) AS host_points
FROM results_table
GROUP BY host_team;

CREATE TEMPORARY TABLE guest_points_table AS
SELECT guest_team, SUM(guest_points) AS guest_points
FROM results_table
GROUP BY guest_team;

CREATE TEMPORARY TABLE points_table AS
SELECT 
t.team_id AS team_id,
t.team_name AS team_name, 
COALESCE(h.host_points, 0) + COALESCE(g.guest_points, 0) AS num_points
FROM host_points_table AS h
FULL JOIN guest_points_table AS g
ON h.host_team = g.guest_team
FULL JOIN teams AS t
ON COALESCE(h.host_team, g.guest_team) = t.team_id
ORDER BY num_points DESC, team_id ASC;

SELECT *
FROM points_table;