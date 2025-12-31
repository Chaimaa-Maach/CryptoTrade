----------------TABLE ORDRE----------------------------

-- Clé étrangère vers utilisateur
--**CONSTRAINT ordre_user_fk FOREIGN KEY (id_user)
--**REFERENCES public.utilisateur (id_user),

	
CREATE OR REPLACE FUNCTION trg_check_ordre_user()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM utilisateur WHERE id_user = NEW.id_user
    ) THEN
        RAISE EXCEPTION 'Utilisateur inexistant: %', NEW.id_user;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ordre_user
BEFORE INSERT OR UPDATE ON ordre
FOR EACH ROW
EXECUTE FUNCTION trg_check_ordre_user();

-- Clé étrangère vers paire_trading
--**CONSTRAINT ordre_paire_fk FOREIGN KEY (id_paire)
--**REFERENCES public.paire_trading (id_paire)


CREATE OR REPLACE FUNCTION trg_check_ordre_paire()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM paire_trading WHERE id_paire = NEW.id_paire
    ) THEN
        RAISE EXCEPTION 'Paire inexistant: %', NEW.id_paire;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ordre_paire
BEFORE INSERT OR UPDATE ON ordre
FOR EACH ROW
EXECUTE FUNCTION trg_check_ordre_paire();


----------------TABLE TRADE----------------------------


-- Clé étrangère vers ordre
--**CONSTRAINT trade_ordre_fk FOREIGN KEY (id_ordre)
--**REFERENCES public.ordre (id_ordre), 

CREATE OR REPLACE FUNCTION trg_check_trade_ordre()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ordre WHERE id_ordre = NEW.id_ordre
    ) THEN
        RAISE EXCEPTION 'Ordre inexistant: %', NEW.id_ordre;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_trade_ordre
BEFORE INSERT OR UPDATE ON trade
FOR EACH ROW
EXECUTE FUNCTION trg_check_trade_ordre();
		
-- Clé étrangère vers paire_trading
--**CONSTRAINT trade_paire_fk FOREIGN KEY (id_paire)
--**REFERENCES public.paire_trading (id_paire)

CREATE OR REPLACE FUNCTION trg_check_trade_paire()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM paire_trading WHERE id_paire = NEW.id_paire
    ) THEN
        RAISE EXCEPTION 'Paire inexistant: %', NEW.id_paire;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_trade_paire
BEFORE INSERT OR UPDATE ON trade
FOR EACH ROW
EXECUTE FUNCTION trg_check_trade_paire();


----------------TABLE AUDIT TRAIL----------------------------
	  
	  
-- Clé étrangère vers utilisateur
--**CONSTRAINT audit_trail_user_fk FOREIGN KEY (id_user)
--**REFERENCES public.utilisateur (id_user)

CREATE OR REPLACE FUNCTION trg_check_audit_user()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM utilisateur WHERE id_user = NEW.id_user
    ) THEN
        RAISE EXCEPTION 'Utilisateur inexistant: %', NEW.id_user;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_user
BEFORE INSERT OR UPDATE ON audit_trail
FOR EACH ROW
EXECUTE FUNCTION trg_check_audit_user();

		
----------------TABLE DETECTION ANOMALIE----------------------------		   

-- Clé étrangère vers ORDRE
--**CONSTRAINT detection_anomalie_ordre_fk FOREIGN KEY (id_ordre)
--**REFERENCES public.ordre (id_ordre),

CREATE OR REPLACE FUNCTION trg_check_detection_ordre()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ordre WHERE id_ordre = NEW.id_ordre
    ) THEN
        RAISE EXCEPTION 'Ordre inexistant: %', NEW.id_ordre;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_detection_ordre
BEFORE INSERT OR UPDATE ON detection_anomalie
FOR EACH ROW
EXECUTE FUNCTION trg_check_detection_ordre();
