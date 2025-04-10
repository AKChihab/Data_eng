SELECT
  u.username,
  COUNT(p.id) AS post_count
FROM {{ ref('users') }} u
LEFT JOIN {{ ref('posts') }} p ON u.id = p.user_id
GROUP BY u.username