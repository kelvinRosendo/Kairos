package com.kairos.features.finance.controller;
import org.springframework.http.*;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;
import java.util.*;
@RestControllerAdvice(basePackages = "com.kairos.features.finance")
public class FinanceErrors {
    @ExceptionHandler(NoSuchElementException.class)
    public ResponseEntity<Map<String,String>> missing(NoSuchElementException error) {
        return ResponseEntity.status(404).body(Map.of("message", "Lançamento não encontrado."));
    }
    @ExceptionHandler({IllegalArgumentException.class, java.time.format.DateTimeParseException.class})
    public ResponseEntity<Map<String,String>> invalid(Exception error) {
        return ResponseEntity.badRequest().body(Map.of("message", error.getMessage()));
    }
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String,String>> validation(MethodArgumentNotValidException error) {
        return ResponseEntity.badRequest().body(Map.of("message", "Confira os campos e use valores com até duas casas decimais."));
    }
}
