# FitGraphs - instrukcja

## Kompilacja oraz instalacja

Minimalne wymagania

1. iOS 17
2. XCode 15
3. Swift 5.9

```code
git pull https://github.com/szymonorz/FitGraphs.git
```

Otwórz projekt w XCode, zbuduj i uruchom na emulatorze iOS 17.

## Logowanie

FitGraph obsługuje logowanie za pomocą Firebase poprze Google OAuth.
Należy nacisnąć na przycisk `Sign In with Google` i udzielić aplikacji na korzystanie danych z konta.

## Pobieranie danych ze Strava

Po zalogowanie na dole ekranu aplikacji są widoczne dwa widoki `Dashboards` i `Settings`. Należy przejść do `Settings` i nacisnąć w przycisk `Sign in with Strava`. Aplikacja przekieruje 

## Tworzenie dashboardów

W widoku `Dashboards` w prawym górnym rogu po naciśnieciu na `+` pokaże się widok gdzie można utworzyć nowy panel. Po utworzeniu należy nacisnąć na dashboard i zostanie się przeniesionym w widok edytora panelu, gdzie można tworzyć wykresy oraz zmienić nazwe. 

## Tworzenie i edycja wykresów.

W widoku edytora lub kreatora wykresów są widoczne 3 pola do edycji: `Filters`, `Splits` oraz `Measures`. W `Filters` podajemy filtry, według których chcemy ograniczyć zbiór danych. W `Splits` podajemy wymiary według których mają być grupowane dane. W `Measures` podajemy statystyki, które mają być wyświetlane na wykresie.

Pod wybieraczkami znajduje się horyzontalny panel w którym można wybrać jeden z 4 rodzai wykresów: `Bar`, `Line`, `Pie`, `Area`.


Musi być podany conajmniej jeden wymiar w `Splits` oraz tylko jedna miara w `Measures`. Ilosć `Splits` jest zależna od rodzaju wykresu. Wykres `Pie` pozwala tylko na jeden wymiar. `Line` oraz `Area` zezwalają tylko na wymiar `Date`. `Bar` ma maksymalny limit dwóch wymiarów.

Po zakończeniu operacji należy zapisać wykres naciskająć przycisk `Save`. Widok nie pozwala zapisać wykresu jeżeli jest on błędny. Komunikaty błędu są wypisywane zamiast wyświetlanego wykresu.

## Tryb Demo

Użytkownik ma możliwość przetestować aplikację bez wymogu posiadania konta naciskając w przycisk `Demo Mode` na panelu logowania. Ma tam już przygotowany jeden dashboard z trzema wykresami. Dane dla trybu demo zawierają zakres aktywności z 2023 roku.