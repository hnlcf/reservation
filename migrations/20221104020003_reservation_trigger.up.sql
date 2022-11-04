-- reservation change queue
CREATE TABLE resv.reservation_changes (
  id SERIAL NOT NULL,
  reservation_id uuid NOT NULL,
  op resv.reservation_change_type NOT NULL
);

-- trigger for add/update/delete a reservation
CREATE OR REPLACE FUNCTION resv.reservations_trigger() RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- update reservation_changes
    INSERT INTO resv.reservation_changes (reservation_id, op) VALUES (NEW.id, 'create');
  ELSIF TG_OP = 'UPDATE' THEN
    -- if status changed, update reservation_changes
    IF OLD.status <> NEW.status THEN
      INSERT INTO resv.reservation_changes (reservation_id, op) VALUES (NEW.id, 'update');
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    -- update reservation_changes
    INSERT INTO resv.reservation_changes (reservation_id, op) VALUES (NEW.id, 'delete');
  END IF;
  -- notify a channel called reservation_update
  NOTIFY reservation_update;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reservations_trigger
    AFTER INSERT OR UPDATE OR DELETE ON resv.reservations
    FOR EACH ROW EXECUTE PROCEDURE resv.reservations_trigger();
