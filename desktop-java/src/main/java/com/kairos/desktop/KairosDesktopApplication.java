package com.kairos.desktop;

import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public class KairosDesktopApplication extends Application {

    @Override
    public void start(Stage stage) {
        Label title = new Label("Kairos");
        Label subtitle = new Label("Seu controle financeiro, no momento certo.");

        VBox root = new VBox(12, title, subtitle);
        root.setPadding(new Insets(24));

        stage.setTitle("Kairos");
        stage.setScene(new Scene(root, 960, 640));
        stage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
