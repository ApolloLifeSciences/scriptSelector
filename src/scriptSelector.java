import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import static java.nio.file.Files.copy;
import java.nio.file.StandardCopyOption;

public class scriptSelector {
    String APPTITLE = "scriptSelector v1.0.1";
    String HOME_FOLDER = System.getProperty("user.home");
    String SCRIPTFOLDER = "scripts";
    String PROGRESSFILE = "scriptSelector_running.txt";
    JFileChooser FILECHOOSER;
    JComboBox combo_script;
    JTextField tf_targetfolder = new JTextField(40);
    JTextField tf_customtext = new JTextField(55);
    JProgressBar pbar = new JProgressBar(0, 100);
    JLabel label_script = new JLabel();
    JLabel label_folder = new JLabel();
    JLabel label_customtext = new JLabel();



    class Task extends SwingWorker<Void, Void> {
        @Override
        protected Void doInBackground() throws Exception {
            pbar.setValue(0);
            pbar.setIndeterminate(true);

            String script = combo_script.getSelectedItem().toString();
            String script_path = SCRIPTFOLDER + "\\" + script;
            String target_folder = tf_targetfolder.getText();
            String new_script_path = target_folder + "\\" + script;
            String customtext = tf_customtext.getText();

            String startCommand = find_Rbin_folder(HOME_FOLDER) + "\\Rscript";
            if(script.endsWith("py")) startCommand = "python";

            ProcessBuilder pb = new ProcessBuilder(startCommand, script_path, target_folder, customtext);
            if(script.endsWith("Rmd")) {
                copyFile(script_path, new_script_path);
                String new_path_forR = new_script_path.replaceAll("\\\\","/");
                print(new_path_forR);
                String rmarkdownCommand = "rmarkdown::render(input='" + new_path_forR + "', params=list(customtext='" + customtext + "'))";
                print(rmarkdownCommand);
                pb = new ProcessBuilder(startCommand, "-e", rmarkdownCommand);
            }

            pb.inheritIO();
            pb.start();

            Thread.sleep(1000);
            while(checkPath(tf_targetfolder.getText() + "\\" + PROGRESSFILE)){
                Thread.sleep(1000);
            }
            pbar.setValue(100);
            pbar.setIndeterminate(false);


            return null;
        }
    }

    public scriptSelector() throws IOException {
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (UnsupportedLookAndFeelException | ClassNotFoundException e) {
            e.printStackTrace();
        } catch (InstantiationException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
        FILECHOOSER = new JFileChooser(); //important to be after the UIManager
        //================================================================
        print("dropdown script selection");
        String[] scriptlist = new File(SCRIPTFOLDER).list();
        combo_script = new JComboBox(scriptlist);
        combo_script.setSelectedIndex(-1);
        combo_script.addActionListener(new ActionListener(){
            @Override
            public void actionPerformed(ActionEvent e) {
                String selected_script = "scripts/" + combo_script.getSelectedItem().toString();
                try {
                    int buffer = 0;
                    if(selected_script.endsWith("Rmd")) buffer = 30;
                    label_script.setText( read_file_lines(selected_script,buffer+3,buffer+3) );
                    label_folder.setText( read_file_lines(selected_script,buffer+4,buffer+4) );
                    label_customtext.setText( read_file_lines(selected_script,buffer+5,buffer+5) );

                    tf_customtext.setEditable(true);
                    if(label_customtext.getText().contains("no effect")){
                        tf_customtext.setEditable(false);
                        label_customtext.setText("");
                    }
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            }
        });
        JPanel panel_script = new JPanel();
        panel_script.add(combo_script);
        //================================================================
        print("define browsing folders panel");
        JPanel panel_folder = create_panel("", tf_targetfolder, HOME_FOLDER,
                "has to contain the files of interest", HOME_FOLDER, true);

        print("define custom string");
        JPanel panel_customtext = create_panel2("", tf_customtext, "",
                "write any arguements for the script");

        print("define run button panel");
        JButton button_run = new JButton(new AbstractAction("run the script") {
            @Override
            public void actionPerformed(ActionEvent e) {
                Task task = new Task();
                task.execute();

            }
        });
        JPanel panel_run = new JPanel();
        panel_run.add(pbar);
        panel_run.add(button_run);
        //================================================================
        print("define explanation panels");
        JPanel panel_explanation_script = new JPanel();
        JPanel panel_explanation_folder = new JPanel();
        JPanel panel_explanation_customtext = new JPanel();
        panel_explanation_script.add(label_script);
        panel_explanation_folder.add(label_folder);
        panel_explanation_customtext.add(label_customtext);
        //================================================================
        print("put all panels together");
        JPanel panel = new JPanel();
        panel.add(panel_explanation_script);
        panel.add(panel_script);
        panel.add(panel_explanation_folder);
        panel.add(panel_folder);
        panel.add(panel_explanation_customtext);
        panel.add(panel_customtext);
        panel.add(panel_run);
        panel.setLayout(new GridLayout(7,1));
        JFrame frame = new JFrame(APPTITLE);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.add(panel);
        frame.pack(); //window size; call before setLocation to place in the middle
        frame.setLocationRelativeTo(null); //place in screen middle
        frame.setVisible(true);
        frame.setSize(800, 300);
    }


    public static void copyFile(String oldPath, String newPath) throws IOException {
        copy(Paths.get(oldPath), Paths.get(newPath), StandardCopyOption.REPLACE_EXISTING);
    }
    public void print(String message) throws IOException {System.out.println(message);}
    public static boolean checkPath(String path) {
        boolean exists = Files.exists(Paths.get(path));
        return exists;
    }
    public static String find_R_folder(String home_folder) throws IOException {
        String possible_folder;
        possible_folder = "C:\\Program Files\\R";
        if(checkPath(possible_folder))  return possible_folder;
        possible_folder = "C:\\Program Files (x86)\\R";
        if(checkPath(possible_folder))  return possible_folder;
        possible_folder = "C:\\ProgramData\\R";
        if(checkPath(possible_folder))  return possible_folder;
        possible_folder = home_folder + "\\R";
        if(checkPath(possible_folder))  return possible_folder;
        possible_folder = home_folder + "\\Documents\\R";
        if(checkPath(possible_folder))  return possible_folder;
        return null;
    }
    public static String find_Rbin_folder(String home_folder) throws IOException {
        String r_folder = find_R_folder(home_folder);
        String[] rcontents = new File(r_folder).list();
        ArrayList rversions_arraylist = new ArrayList();
        for (String content : rcontents) {
            if (content.startsWith("R-"))
                rversions_arraylist.add(content);
        }
        String[] rversions = new String[rversions_arraylist.size()];
        rversions = (String[]) rversions_arraylist.toArray(rversions);
        String rbin_folder = r_folder + "\\" + rversions[rversions.length - 1] + "\\bin";
        return rbin_folder;
    }
    public JPanel create_panel(String name, JTextField tf, String tfText, String tooltip, String browseStart, boolean browseFolder){
        JPanel panel = new JPanel(new FlowLayout(FlowLayout.RIGHT));

        //define textfield
        tf.setText(tfText);
        tf.setToolTipText(tooltip);

        //define browse button
        JButton browse = new JButton(new AbstractAction("browse") {
            @Override
            public void actionPerformed(ActionEvent e) {
                String curdir = tf.getText();
                if(!checkPath(curdir)) curdir = browseStart;
                FILECHOOSER.setCurrentDirectory(new File(curdir));
                FILECHOOSER.setDialogTitle("choose " + name);
                FILECHOOSER.setFileSelectionMode(FILECHOOSER.FILES_ONLY);
                if(browseFolder) FILECHOOSER.setFileSelectionMode(FILECHOOSER.DIRECTORIES_ONLY);
                FILECHOOSER.setAcceptAllFileFilterUsed(false);
                if (FILECHOOSER.showOpenDialog(panel) == JFileChooser.APPROVE_OPTION) {
                    String selectedFile = FILECHOOSER.getSelectedFile().getAbsolutePath();
                    tf.setText(selectedFile);
                }
            }
        });
        browse.setToolTipText(tooltip);

        //define open button
        JButton open = new JButton(new AbstractAction("open") {
            @Override
            public void actionPerformed(ActionEvent e) {
                try {
                    String path = tf.getText();
                    Desktop.getDesktop().open(new File(path));
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            }
        });

        //complete panel
        panel.add(new JLabel(name));
        panel.add(tf);
        panel.add(browse);
        panel.add(open);
        return panel;
    }
    public JPanel create_panel2(String name, JTextField tf, String tfText, String tooltip){
        JPanel panel = new JPanel(new FlowLayout(FlowLayout.RIGHT));

        //define textfield
        tf.setText(tfText);
        tf.setToolTipText(tooltip);

        //complete panel
        panel.add(new JLabel(name));
        panel.add(tf);
        return panel;
    }
    public String read_file_lines(String path, int startline, int endline) throws IOException {
        BufferedReader bufferedReader = new BufferedReader(new FileReader(path));
        int current_line = 0;

        String script_text = "<html><body>";
        while(current_line < endline) {
            String current_text = bufferedReader.readLine();
            if (current_line >= startline-1) script_text = script_text + "<br>" + current_text;
            current_line++;
        }
        script_text = script_text + "</body></html>";

        bufferedReader.close();
        return script_text;
    }

    public static void loggme(String str) throws IOException {
        BufferedWriter writer = new BufferedWriter(new FileWriter("log.txt"));
        writer.write(str);
        writer.close();
    }
    public static void main(String[] args) throws IOException {
        new scriptSelector();
    }
}
