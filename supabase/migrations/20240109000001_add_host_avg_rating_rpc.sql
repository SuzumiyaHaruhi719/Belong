-- RPC to get average host rating from gathering feedback
CREATE OR REPLACE FUNCTION get_host_avg_rating(p_host_id UUID)
RETURNS TABLE(avg_rating DOUBLE PRECISION) AS $$
BEGIN
  RETURN QUERY
  SELECT COALESCE(AVG(gf.rating::DOUBLE PRECISION), 0.0) as avg_rating
  FROM gathering_feedback gf
  JOIN gatherings g ON g.id = gf.gathering_id
  WHERE g.host_id = p_host_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
