CREATE TYPE resv.reservation_status AS ENUM ('unknown', 'pending', 'confirmed', 'blocked');
CREATE TYPE resv.reservation_change_type AS ENUM ('unknown', 'create', 'update', 'delete');

CREATE TABLE resv.reservations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id VARCHAR(64) NOT NULL,
  status resv.reservation_status NOT NULL DEFAULT 'pending',

  resource_id VARCHAR(64) NOT NULL,
  timespan TSTZRANGE NOT NULL,
  note TEXT,

  CONSTRAINT reservations_pkey PRIMARY KEY (id),
  CONSTRAINT reservations_conflict EXCLUDE USING gist(resource_id WITH =, timespan WITH &&)
);

CREATE INDEX reservations_resource_id_idx ON resv.reservations (resource_id);
CREATE INDEX reservations_user_id_idx ON resv.reservations (user_id);
