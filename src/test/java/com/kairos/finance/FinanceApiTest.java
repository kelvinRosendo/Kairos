package com.kairos.finance;

import com.kairos.KairosApplication;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.http.MediaType;
import java.util.UUID;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(classes = KairosApplication.class, properties = {
    "spring.datasource.url=jdbc:h2:mem:kairos;MODE=PostgreSQL;DB_CLOSE_DELAY=-1",
    "spring.datasource.driver-class-name=org.h2.Driver", "spring.datasource.username=sa", "spring.datasource.password=",
    "spring.jpa.hibernate.ddl-auto=validate"
})
@AutoConfigureMockMvc
class FinanceApiTest {
    @Autowired MockMvc mvc;
    @Test void completeFlowPersistsAndRetryDoesNotDuplicate() throws Exception {
        mvc.perform(put("/api/finance/opening-balance").contentType(MediaType.APPLICATION_JSON)
            .content("{\"amount\":800.00,\"referenceDate\":\"2026-01-01\"}"))
            .andExpect(status().isOk());
        String id = UUID.randomUUID().toString();
        String payload = "{\"type\":\"EXPENSE\",\"description\":\"Internet\",\"amount\":\"99.90\",\"expectedDate\":\"2026-01-12\",\"recurring\":false}";
        for (int i = 0; i < 2; i++) {
            mvc.perform(post("/api/entries").header("Idempotency-Key", id).contentType(MediaType.APPLICATION_JSON).content(payload))
                .andExpect(status().isCreated()).andExpect(jsonPath("$.id").value(id));
        }
        mvc.perform(get("/api/entries?month=2026-01")).andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(1));
        mvc.perform(patch("/api/entries/" + id + "/settle?date=2026-01-12")).andExpect(status().isOk());
        mvc.perform(get("/api/finance/summary?month=2026-01")).andExpect(jsonPath("$.current").value(700.10));
        mvc.perform(patch("/api/entries/" + id + "/reopen")).andExpect(status().isOk()).andExpect(jsonPath("$.status").value("PLANNED"));
        mvc.perform(patch("/api/entries/" + id + "/cancel")).andExpect(status().isOk());
        mvc.perform(get("/api/finance/summary?month=2026-01")).andExpect(jsonPath("$.current").value(800.00));
        mvc.perform(post("/api/entries").contentType(MediaType.APPLICATION_JSON).content(payload.replace("99.90", "99.999")))
            .andExpect(status().isBadRequest());
    }
}
